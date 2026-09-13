import pool from "../config/db.config.js";
import os from "os";

let previousCpuSample = null;

const getServerPerformance = (dbLatencyMs) => {
  const currentCpu = process.cpuUsage();
  const currentTime = process.hrtime.bigint();
  let cpuPercent = 0;
  if (previousCpuSample) {
    const elapsedMicros = Number(currentTime - previousCpuSample.time) / 1000;
    const cpuMicros =
      currentCpu.user -
      previousCpuSample.cpu.user +
      currentCpu.system -
      previousCpuSample.cpu.system;
    cpuPercent = elapsedMicros > 0 ? (cpuMicros / elapsedMicros) * 100 : 0;
  }
  previousCpuSample = { cpu: currentCpu, time: currentTime };

  const memory = process.memoryUsage();
  const totalMemory = os.totalmem();
  const freeMemory = os.freemem();
  const cpuCount = os.cpus().length || 1;

  return {
    cpuPercent: Math.min(100, Math.round(cpuPercent * 10) / 10),
    cpuCount,
    loadAverage: os.loadavg()[0] || 0,
    memoryRssMb: Math.round(memory.rss / 1024 / 1024),
    heapUsedMb: Math.round(memory.heapUsed / 1024 / 1024),
    heapTotalMb: Math.round(memory.heapTotal / 1024 / 1024),
    totalMemoryMb: Math.round(totalMemory / 1024 / 1024),
    freeMemoryMb: Math.round(freeMemory / 1024 / 1024),
    memoryPercent:
      Math.round(((totalMemory - freeMemory) / totalMemory) * 1000) / 10,
    dbLatencyMs,
    uptimeSeconds: Math.round(process.uptime()),
    nodeVersion: process.version,
    platform: `${process.platform} ${process.arch}`,
    pid: process.pid,
  };
};

const auditVisibilityEnabled = async () => {
  try {
    const [[setting]] = await pool.query(
      "SELECT setting_value FROM system_settings WHERE setting_key = 'audit_activity_visibility'",
    );
    return setting?.setting_value !== "0";
  } catch {
    return true;
  }
};

const requireAuditVisibility = async (res) => {
  if (await auditVisibilityEnabled()) return true;
  res.status(403).json({
    Status: false,
    Error:
      "Auditor activity visibility is disabled by the server administrator",
  });
  return false;
};

export const getAuditOverview = async (req, res) => {
  try {
    if (!(await requireAuditVisibility(res))) return;
    const dbStarted = performance.now();
    const [summary, actions, entities, actors, hourly] = await Promise.all([
      pool.query(`
        SELECT
          COUNT(*) AS total,
          SUM(CASE WHEN created_at >= NOW() - INTERVAL 24 HOUR THEN 1 ELSE 0 END) AS last_24_hours,
          SUM(CASE WHEN created_at >= NOW() - INTERVAL 1 HOUR THEN 1 ELSE 0 END) AS last_hour,
          COUNT(DISTINCT user_id) AS actors,
          COUNT(DISTINCT entity_type) AS entities
        FROM audit_logs`),
      pool.query(`
        SELECT action, COUNT(*) AS count
        FROM audit_logs
        WHERE created_at >= NOW() - INTERVAL 24 HOUR
        GROUP BY action
        ORDER BY count DESC
        LIMIT 8`),
      pool.query(`
        SELECT COALESCE(entity_type, 'system') AS entity_type, COUNT(*) AS count
        FROM audit_logs
        WHERE created_at >= NOW() - INTERVAL 24 HOUR
        GROUP BY COALESCE(entity_type, 'system')
        ORDER BY count DESC
        LIMIT 8`),
      pool.query(`
        SELECT COALESCE(u.full_name, 'System') AS name, COUNT(*) AS count
        FROM audit_logs al
        LEFT JOIN users u ON u.id = al.user_id
        WHERE al.created_at >= NOW() - INTERVAL 24 HOUR
        GROUP BY COALESCE(u.full_name, 'System')
        ORDER BY count DESC
        LIMIT 8`),
      pool.query(`
        SELECT DATE_FORMAT(created_at, '%H:00') AS hour, COUNT(*) AS count
        FROM audit_logs
        WHERE created_at >= NOW() - INTERVAL 24 HOUR
        GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d %H'), DATE_FORMAT(created_at, '%H:00')
        ORDER BY MIN(created_at)`),
    ]);
    const dbLatencyMs = Math.round(performance.now() - dbStarted);

    res.json({
      Status: true,
      data: {
        summary: Object.fromEntries(
          Object.entries(summary[0][0]).map(([key, value]) => [
            key,
            Number(value || 0),
          ]),
        ),
        actions: actions[0],
        entities: entities[0],
        actors: actors[0],
        hourly: hourly[0],
        performance: getServerPerformance(dbLatencyMs),
        generated_at: new Date().toISOString(),
      },
    });
  } catch (err) {
    console.error("Audit overview query failed:", err.message);
    res.status(500).json({ Status: false, Error: err.message });
  }
};
import { logAction } from "../utils/audit.js";

// GET /audit/logs — accessible only through the isolated auditor role
export const getAuditLogs = async (req, res) => {
  const {
    action,
    entity_type: entityType,
    user_id: userId,
    from,
    to,
    page = 1,
    limit = 50,
  } = req.query;
  const where = [];
  const params = [];
  if (action) {
    where.push("al.action = ?");
    params.push(action);
  }
  if (entityType) {
    where.push("al.entity_type = ?");
    params.push(entityType);
  }
  if (userId) {
    where.push("al.user_id = ?");
    params.push(userId);
  }
  if (from) {
    where.push("DATE(al.created_at) >= ?");
    params.push(from);
  }
  if (to) {
    where.push("DATE(al.created_at) <= ?");
    params.push(to);
  }
  const whereClause = where.length ? `WHERE ${where.join(" AND ")}` : "";
  const pageNumber = Math.max(Number(page) || 1, 1);
  const pageSize = Math.min(Math.max(Number(limit) || 50, 1), 100);

  try {
    if (!(await requireAuditVisibility(res))) return;
    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM audit_logs al ${whereClause}`,
      params,
    );
    const [rows] = await pool.query(
      `
      SELECT al.*, u.username, u.full_name, u.role
      FROM audit_logs al
      LEFT JOIN users u ON u.id = al.user_id
      ${whereClause}
      ORDER BY al.id DESC
      LIMIT ? OFFSET ?`,
      [...params, pageSize, (pageNumber - 1) * pageSize],
    );
    res.json({
      Status: true,
      data: rows,
      pagination: { page: pageNumber, limit: pageSize, total },
    });
    void logAction({
      userId: req.user.id,
      action: "audit.viewed",
      entityType: "audit_log",
      details: { page: pageNumber },
      req,
    });
  } catch (err) {
    res.status(500).json({ Status: false, Error: err.message });
  }
};

export const getAuditFilterOptions = async (req, res) => {
  try {
    if (!(await requireAuditVisibility(res))) return;
    const [actions, entities, users] = await Promise.all([
      pool.query("SELECT DISTINCT action FROM audit_logs ORDER BY action"),
      pool.query(
        "SELECT DISTINCT entity_type FROM audit_logs WHERE entity_type IS NOT NULL ORDER BY entity_type",
      ),
      pool.query(
        "SELECT DISTINCT u.id, u.full_name, u.username FROM audit_logs al JOIN users u ON u.id=al.user_id ORDER BY u.full_name",
      ),
    ]);
    res.json({
      Status: true,
      data: { actions: actions[0], entityTypes: entities[0], users: users[0] },
    });
  } catch (err) {
    res.status(500).json({ Status: false, Error: err.message });
  }
};
