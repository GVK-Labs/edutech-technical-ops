import pool from "../config/db.config.js";
import mysql from "mysql2";

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

const quoteIdentifier = (identifier) =>
  `\`${String(identifier).replaceAll("`", "``")}\``;

const createInsertStatement = (tableName, columns, row) => {
  const values = columns.map((column) => mysql.escape(row[column])).join(", ");
  return `INSERT INTO ${quoteIdentifier(tableName)} (${columns
    .map(quoteIdentifier)
    .join(", ")}) VALUES (${values});`;
};

export const exportDatabaseSql = async (req, res) => {
  try {
    const [tableRows] = await pool.query(
      "SHOW FULL TABLES WHERE Table_type = 'BASE TABLE'",
    );
    const tableKey = Object.keys(tableRows[0] || {}).find(
      (key) => key !== "Table_type",
    );
    const chunks = [
      "-- Smartboard OPS Management database backup",
      `-- Generated at ${new Date().toISOString()}`,
      "SET FOREIGN_KEY_CHECKS=0;",
      "",
    ];

    for (const tableRow of tableRows) {
      const tableName = tableRow[tableKey];
      const [[createTable]] = await pool.query(
        `SHOW CREATE TABLE ${quoteIdentifier(tableName)}`,
      );
      const createStatement = createTable["Create Table"];
      const [rows] = await pool.query(
        `SELECT * FROM ${quoteIdentifier(tableName)}`,
      );
      const columns = rows.length
        ? Object.keys(rows[0])
        : (
            await pool.query(`SHOW COLUMNS FROM ${quoteIdentifier(tableName)}`)
          )[0].map((column) => column.Field);

      chunks.push(`DROP TABLE IF EXISTS ${quoteIdentifier(tableName)};`);
      chunks.push(`${createStatement};`);
      for (const row of rows) {
        chunks.push(createInsertStatement(tableName, columns, row));
      }
      chunks.push("");
    }

    chunks.push("SET FOREIGN_KEY_CHECKS=1;", "");
    const filename = `smartboard_ops_backup_${new Date().toISOString().slice(0, 10)}.sql`;
    res.setHeader("Content-Type", "application/sql; charset=utf-8");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename=\"${filename}\"`,
    );
    res.send(chunks.join("\n"));
  } catch (err) {
    console.error("Database SQL export failed:", err);
    res
      .status(500)
      .json({ success: false, message: "Failed to export database" });
  }
};
