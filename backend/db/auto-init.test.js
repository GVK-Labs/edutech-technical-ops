import test from "node:test";
import assert from "node:assert/strict";
import { hasRequiredInitialization } from "./auto-init.js";

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
