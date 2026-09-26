import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, DatabaseBackup, Download } from "lucide-react";
import { toast } from "sonner";
import axios from "@/utils/axios";
import { API_URL } from "@/lib/api";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export default function BackupSettings() {
  const navigate = useNavigate();
  const [exporting, setExporting] = useState(false);

  const handleExport = async () => {
    setExporting(true);
    try {
      const response = await axios.get(`${API_URL}/settings/backup`, {
        responseType: "blob",
      });
      const url = window.URL.createObjectURL(response.data);
      const link = document.createElement("a");
      link.href = url;
      link.download = "smartboard_ops_backup.sql";
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
      toast.success("Database backup downloaded");
    } catch {
      toast.error("Failed to export database backup");
    } finally {
      setExporting(false);
    }
  };

  return (
    <main className="overflow-y-auto p-5">
      <div className="mb-6 flex items-center gap-4">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate("/app/settings")}
          className="gap-2"
        >
          <ArrowLeft className="h-4 w-4" /> Back
        </Button>
      </div>

      <Card className="max-w-2xl">
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="rounded-lg bg-amber-50 p-3 text-amber-600">
              <DatabaseBackup className="h-6 w-6" />
            </div>
            <div>
              <CardTitle>Database Backup</CardTitle>
              <CardDescription>
                Export all database tables and records as a SQL file.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Button onClick={handleExport} disabled={exporting} className="gap-2">
            <Download className="h-4 w-4" />
            {exporting ? "Preparing backup..." : "Export SQL Backup"}
          </Button>
        </CardContent>
      </Card>
    </main>
  );
}
