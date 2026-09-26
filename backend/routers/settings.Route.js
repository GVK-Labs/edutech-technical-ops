import express from "express";
import { verifyAdmin } from "../middleware/auth.js";

import {
  exportDatabaseSql,
  getSystemSettings,
  getPublicBranding,
  updateSystemSettings,
} from "../controllers/settings.Controller.js";

const router = express.Router();

// Public settings used by the frontend before login
router.get("/branding", getPublicBranding);
router.get("/system", getSystemSettings);

// Only administrators can modify system settings
router.put("/system", ...verifyAdmin, updateSystemSettings);
router.get("/backup", ...verifyAdmin, exportDatabaseSql);

export default router;
