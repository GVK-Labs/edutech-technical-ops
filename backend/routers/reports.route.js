import express from "express";
import {
  getAssemblyDetails,
  exportAssemblyDetailsExcel,
  exportInventoryExcel,
  exportAssemblyDetailsPDF,
  getUnitHistory,
  getTechnicianPerformance,
  getInventoryConsumption,
  getJobProgress,
} from "../controllers/reports.controller.js";
import { verifyToken, verifyManager } from "../middleware/auth.js";

const router = express.Router();

router.get("/assembly-details", verifyToken, verifyManager, getAssemblyDetails);
router.get(
  "/assembly-details/export/excel",
  verifyToken,
  verifyManager,
  exportAssemblyDetailsExcel,
);
router.get(
  "/inventory/export/excel",
  verifyToken,
  verifyManager,
  exportInventoryExcel,
);
router.get(
  "/assembly-details/export/pdf",
  verifyToken,
  verifyManager,
  exportAssemblyDetailsPDF,
);

router.get("/unit-history", verifyToken, verifyManager, getUnitHistory);
router.get(
  "/technician-performance",
  verifyToken,
  verifyManager,
  getTechnicianPerformance,
);
router.get(
  "/inventory-consumption",
  verifyToken,
  verifyManager,
  getInventoryConsumption,
);
router.get("/job-progress", verifyToken, verifyManager, getJobProgress);

export default router;
