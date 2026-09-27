import test from "node:test";
import assert from "node:assert/strict";
import {
  getDefaultDatabaseName,
  hasRequiredInitialization,
} from "./auto-init.js";

test("default database name matches the Aiven target", () => {
  const previous = process.env.DB_NAME;
  delete process.env.DB_NAME;
  assert.equal(getDefaultDatabaseName(), "defaultdb");
  if (previous === undefined) delete process.env.DB_NAME;
  else process.env.DB_NAME = previous;
});

test("skip initialization only when the required auth schema exists", () => {
  assert.equal(
    hasRequiredInitialization([
      "users",
      "jobs",
      "inventory_ops",
      "system_settings",
      "audit_logs",
    ]),
    true,
  );

  assert.equal(
    hasRequiredInitialization([
      "users",
      "jobs",
      "inventory_ops",
      "system_settings",
    ]),
    false,
  );

  assert.equal(hasRequiredInitialization(["users", "jobs"]), false);
});
