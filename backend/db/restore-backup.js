import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const dbName = process.env.DB_NAME || "defaultdb";
const sslConfig = process.env.DB_SSL_CA
  ? {
      ca: process.env.DB_SSL_CA,
      rejectUnauthorized: true,
    }
  : process.env.DB_USE_SSL === "true"
    ? {
        rejectUnauthorized: false,
      }
    : undefined;

function splitSqlStatements(sql) {
  const statements = [];
  let delimiter = ";";
  let buffer = [];

  for (const line of sql.split(/\r?\n/)) {
    const delimiterMatch = line.match(/^\s*DELIMITER\s+(\S+)\s*$/i);
    if (delimiterMatch) {
      delimiter = delimiterMatch[1];
      continue;
    }

    buffer.push(line);
    if (line.trimEnd().endsWith(delimiter)) {
      const statement = buffer.join("\n").trim();
      const withoutDelimiter = statement.slice(0, -delimiter.length).trim();
      if (withoutDelimiter) statements.push(withoutDelimiter);
      buffer = [];
    }
  }

  const remainder = buffer.join("\n").trim();
  if (remainder) statements.push(remainder);
  return statements;
}

async function resetDatabase(conn) {
  const [rows] = await conn.query("SHOW TABLES");
  const tables = rows.map((row) => Object.values(row)[0]);

  if (tables.length === 0) {
    console.log("ℹ️ No tables to reset.");
    return;
  }

  await conn.query("SET FOREIGN_KEY_CHECKS = 0");
  try {
    for (const table of tables) {
      await conn.query(`DROP TABLE IF EXISTS \`${table}\``);
    }
  } finally {
    await conn.query("SET FOREIGN_KEY_CHECKS = 1");
  }

  console.log(`🧹 Dropped ${tables.length} tables before restore.`);
}

async function restoreFromBackup() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || "localhost",
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD ?? "",
    multipleStatements: true,
    charset: "utf8mb4",
    ssl: sslConfig,
  });

  await connection.query(
    `CREATE DATABASE IF NOT EXISTS \`${dbName}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`,
  );
  await connection.query(`USE \`${dbName}\``);

  await resetDatabase(connection);

  const backupFile = path.join(
    __dirname,
    "smartboard_ops_management_backup.sql",
  );
  const raw = fs.readFileSync(backupFile, "utf8");

  for (const statement of splitSqlStatements(raw)) {
    const sqlWithoutComments = statement
      .replace(/^\s*(?:--[^\n]*\n|\/\*[\s\S]*?\*\/\s*)*/g, "")
      .trim();
    if (/^(CREATE\s+DATABASE|USE)\b/i.test(sqlWithoutComments)) continue;
    await connection.query(statement);
  }

  const [[{ count: tableCount }]] = await connection.query(
    "SELECT COUNT(*) AS count FROM information_schema.TABLES WHERE TABLE_SCHEMA = ?",
    [dbName],
  );
  const [[{ count: userCount }]] = await connection.query(
    "SELECT COUNT(*) AS count FROM users",
  );

  console.log(
    `✅ Restore complete. Tables: ${tableCount}, Users: ${userCount}`,
  );
  await connection.end();
}

restoreFromBackup().catch((err) => {
  console.error("❌ Clean backup restore failed:", err.message);
  process.exit(1);
});
