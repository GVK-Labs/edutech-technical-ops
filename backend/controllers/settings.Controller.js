import pool from "../config/db.config.js";

const INIT_SQL = `
CREATE TABLE IF NOT EXISTS system_settings (
  id INT NOT NULL AUTO_INCREMENT,
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_setting_key (setting_key)
) ENGINE=InnoDB;
`;

const SEED_SQL = `
INSERT IGNORE INTO system_settings (setting_key, setting_value) VALUES
  ('system_name', 'Smartboard OPS Management'),
  ('system_logo_url', NULL),
  ('primary_color', '#0ea5e9'),
  ('audit_activity_visibility', '1');
`;

const ensureTable = async () => {
  await pool.query(INIT_SQL);
  await pool.query(SEED_SQL);
};

export const getSystemSettings = async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await pool.query(
      "SELECT setting_key, setting_value FROM system_settings",
    );
    const data = Object.fromEntries(
      rows.map((r) => [r.setting_key, r.setting_value]),
    );
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

export const getPublicBranding = async (req, res) => {
  try {
    await ensureTable();
    const [rows] = await pool.query(
      "SELECT setting_key, setting_value FROM system_settings WHERE setting_key IN ('system_name', 'system_logo_url')",
    );
    const settings = Object.fromEntries(
      rows.map((row) => [row.setting_key, row.setting_value]),
    );
    res.json({
      success: true,
      data: {
        system_name: settings.system_name || "Smartboard OPS Management",
        system_logo_url: settings.system_logo_url || null,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

export const updateSystemSettings = async (req, res) => {
  const { settings } = req.body;
  if (!settings || typeof settings !== "object")
    return res
      .status(400)
      .json({ success: false, message: "Invalid settings format" });
  try {
    await ensureTable();
    for (const [key, value] of Object.entries(settings)) {
      await pool.query(
        "INSERT INTO system_settings (setting_key, setting_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE setting_value = ?",
        [key, value, value],
      );
    }
    res.json({ success: true, message: "Settings updated" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

const escapeSqlValue = (value) => {
  if (value === null || value === undefined) return "NULL";
  if (Buffer.isBuffer(value)) return `X'${value.toString("hex")}'`;
  if (value instanceof Date)
    return `'${value.toISOString().slice(0, 19).replace("T", " ")}'`;
  if (typeof value === "number") return Number.isFinite(value) ? `${value}` : "NULL";
  if (typeof value === "boolean") return value ? "1" : "0";
  return `'${String(value)
    .replace(/\\/g, "\\\\")
    .replace(/'/g, "\\'")
    .replace(/\n/g, "\\n")
    .replace(/\r/g, "\\r")}'`;
};

export const exportDatabaseBackup = async (req, res) => {
  try {
    const [dbRows] = await pool.query("SELECT DATABASE() AS db_name");
    const databaseName = dbRows[0]?.db_name || "database";

    const [tableRows] = await pool.query("SHOW TABLES");
    const tableNames = tableRows.map((row) => Object.values(row)[0]).filter(Boolean);

    const now = new Date();
    const timestamp = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(
      2,
      "0",
    )}${String(now.getDate()).padStart(2, "0")}_${String(
      now.getHours(),
    ).padStart(2, "0")}${String(now.getMinutes()).padStart(2, "0")}${String(
      now.getSeconds(),
    ).padStart(2, "0")}`;

    const lines = [
      `-- Backup of ${databaseName}`,
      `-- Generated at ${now.toISOString()}`,
      "SET NAMES utf8mb4;",
      "SET FOREIGN_KEY_CHECKS=0;",
      "",
    ];

    for (const tableName of tableNames) {
      const [createRows] = await pool.query(`SHOW CREATE TABLE \`${tableName}\``);
      const createTableSql =
        createRows[0]?.["Create Table"] ||
        createRows[0]?.[Object.keys(createRows[0]).find((key) => key.includes("Create Table"))];

      if (!createTableSql) continue;

      lines.push(`-- Table: ${tableName}`);
      lines.push(`DROP TABLE IF EXISTS \`${tableName}\`;`);
      lines.push(`${createTableSql};`);

      const [rows] = await pool.query(`SELECT * FROM \`${tableName}\``);

      if (rows.length) {
        const columnNames = Object.keys(rows[0]).map((column) => `\`${column}\``).join(", ");
        lines.push(`INSERT INTO \`${tableName}\` (${columnNames}) VALUES`);

        const valueLines = rows.map((row) => {
          const values = Object.keys(row)
            .map((column) => escapeSqlValue(row[column]))
            .join(", ");
          return `(${values})`;
        });

        lines.push(`${valueLines.join(",\n")};`);
      }

      lines.push("");
    }

    lines.push("SET FOREIGN_KEY_CHECKS=1;");
    lines.push("");

    const dump = lines.join("\n");

    res.setHeader("Content-Type", "application/sql");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="${databaseName}_backup_${timestamp}.sql"`,
    );
    res.send(dump);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
