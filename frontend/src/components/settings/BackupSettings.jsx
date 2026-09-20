import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Database, Download, Loader2 } from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import axios from "@/utils/axios";
import { API_URL } from "@/lib/api";
import { toast } from "sonner";

export default function BackupSettings() {
  const navigate = useNavigate();
  const [exporting, setExporting] = useState(false);

  const exportCompleteDb = async () => {
    setExporting(true);
    try {
      const response = await axios.get(`${API_URL}/settings/backup/export-db`, {
        responseType: "blob",
      });
      const blob = new Blob([response.data], { type: "application/sql" });
      const objectUrl = window.URL.createObjectURL(blob);
      const link = document.createElement("a");
      const contentDisposition = response.headers["content-disposition"] || "";
      const filenameMatch = contentDisposition.match(/filename="([^"]+)"/i);
      link.href = objectUrl;
      link.download = filenameMatch?.[1] || `complete_database_backup_${Date.now()}.sql`;
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(objectUrl);
      toast.success("Database backup exported");
    } catch {
      toast.error("Failed to export complete database backup");
    } finally {
      setExporting(false);
    }
  };

  return (
    <main className="overflow-y-auto p-5">
      <div className="flex items-center gap-4 mb-6">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate("/app/settings")}
          className="gap-2"
        >
          <ArrowLeft className="h-4 w-4" /> Back
        </Button>
      </div>

      <div className="max-w-2xl">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Database className="h-5 w-5" /> Backup
            </CardTitle>
            <CardDescription>
              Export the complete database as a SQL backup file.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Button onClick={exportCompleteDb} disabled={exporting}>
              {exporting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Exporting...
                </>
              ) : (
                <>
                  <Download className="mr-2 h-4 w-4" />
                  Export Complete DB
                </>
              )}
            </Button>
          </CardContent>
        </Card>
      </div>
    </main>
  );
}
