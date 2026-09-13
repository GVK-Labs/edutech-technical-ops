import { memo, useCallback, useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { CartesianGrid, Line, LineChart, XAxis, YAxis } from "recharts";
import {
  Activity,
  BarChart3,
  Cpu,
  FileSearch,
  Gauge,
  HardDrive,
  LogOut,
  RefreshCw,
  Server,
  ShieldCheck,
  Users,
  Zap,
} from "lucide-react";
import axios from "@/utils/axios";
import { API_URL } from "@/lib/api";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const pretty = (value) =>
  value
    ?.replaceAll("_", " ")
    .replace(/\b\w/g, (letter) => letter.toUpperCase()) || "—";
const readableDetails = (value) => {
  if (!value) return "—";
  try {
    const parsed = typeof value === "string" ? JSON.parse(value) : value;
    return Object.entries(parsed)
      .map(
        ([key, item]) =>
          `${pretty(key)}: ${typeof item === "object" ? JSON.stringify(item) : item}`,
      )
      .join(" · ");
  } catch {
    return String(value);
  }
};
const emptyOverview = {
  summary: {},
  actions: [],
  entities: [],
  actors: [],
  hourly: [],
  performance: {},
  generated_at: null,
};

const activityChartConfig = {
  events: {
    label: "Events",
    color: "var(--chart-1)",
  },
};

const getHeapPercent = (performance) =>
  performance?.heapTotalMb
    ? (Number(performance.heapUsedMb || 0) / Number(performance.heapTotalMb)) *
      100
    : 0;

function ResourceGraph({ title, value, color, data, dataKey }) {
  return (
    <div className="min-w-0 rounded-lg border bg-card p-3">
      <div className="mb-2 flex items-end justify-between gap-2">
        <div>
          <p className="text-xs font-medium text-muted-foreground">{title}</p>
          <p className="font-mono text-2xl font-semibold tabular-nums">
            {value.toFixed(1)}%
          </p>
        </div>
        <span className="text-[10px] text-muted-foreground">60 sec</span>
      </div>
      <div className="h-32 min-w-0">
        <ChartContainer
          config={{ metric: { label: title, color } }}
          className="h-full w-full aspect-auto"
        >
          <LineChart
            data={data}
            margin={{ top: 5, right: 4, bottom: 0, left: 0 }}
          >
            <CartesianGrid strokeDasharray="2 3" />
            <XAxis dataKey="sample" hide />
            <YAxis
              domain={[0, 100]}
              ticks={[0, 50, 100]}
              width={25}
              tickLine={false}
              axisLine={false}
              tick={{ fontSize: 9 }}
            />
            <Line
              dataKey={dataKey}
              type="monotone"
              stroke={color}
              strokeWidth={2}
              dot={false}
              isAnimationActive={false}
            />
          </LineChart>
        </ChartContainer>
      </div>
    </div>
  );
}

const sameRows = (previous, next) => {
  if (previous.length !== next.length) return false;
  return previous.every((row, index) => {
    const candidate = next[index];
    return (
      row.id === candidate.id &&
      row.created_at === candidate.created_at &&
      row.action === candidate.action &&
      row.entity_type === candidate.entity_type &&
      row.entity_id === candidate.entity_id &&
      row.details === candidate.details &&
      row.ip_address === candidate.ip_address &&
      row.full_name === candidate.full_name &&
      row.username === candidate.username
    );
  });
};

const AuditLogRow = memo(function AuditLogRow({ log }) {
  return (
    <tr className="border-b last:border-0 align-top">
      <td className="whitespace-nowrap px-4 py-3 text-xs text-muted-foreground">
        {new Date(log.created_at).toLocaleString("en-GB")}
      </td>
      <td className="px-4 py-3">
        <p className="font-medium">{log.full_name || "System"}</p>
        <p className="text-xs text-muted-foreground">{log.username || "—"}</p>
      </td>
      <td className="px-4 py-3">
        <Badge variant="outline">{log.action}</Badge>
      </td>
      <td className="px-4 py-3 text-xs">
        {pretty(log.entity_type)}
        {log.entity_id ? ` #${log.entity_id}` : ""}
      </td>
      <td className="max-w-xs break-words px-4 py-3 text-xs text-muted-foreground">
        {readableDetails(log.details)}
      </td>
      <td className="px-4 py-3 font-mono text-xs text-muted-foreground">
        {log.ip_address || "—"}
      </td>
    </tr>
  );
});

export default function AuditPortal() {
  const navigate = useNavigate();
  const [authorised, setAuthorised] = useState(null);
  const [logs, setLogs] = useState([]);
  const [options, setOptions] = useState({
    actions: [],
    entityTypes: [],
    users: [],
  });
  const [filters, setFilters] = useState({
    action: "all",
    entityType: "all",
    userId: "all",
    from: "",
    to: "",
  });
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [pagination, setPagination] = useState({ total: 0, limit: 50 });
  const [overview, setOverview] = useState(emptyOverview);
  const [live, setLive] = useState(false);
  const [performanceHistory, setPerformanceHistory] = useState([]);
  const hasLoadedLogs = useRef(false);

  useEffect(() => {
    axios
      .get(`${API_URL}/auth/me`)
      .then((response) => setAuthorised(response.data.user?.role === "auditor"))
      .catch(() => setAuthorised(false));
  }, []);

  const load = useCallback(async () => {
    if (!authorised) return;
    setLoading(!hasLoadedLogs.current);
    try {
      const params = new URLSearchParams({ page: String(page), limit: "50" });
      if (filters.action !== "all") params.set("action", filters.action);
      if (filters.entityType !== "all")
        params.set("entity_type", filters.entityType);
      if (filters.userId !== "all") params.set("user_id", filters.userId);
      if (filters.from) params.set("from", filters.from);
      if (filters.to) params.set("to", filters.to);
      const [logsResponse, optionsResponse] = await Promise.all([
        axios.get(`${API_URL}/audit/logs?${params}`),
        axios.get(`${API_URL}/audit/filters`),
      ]);
      const nextLogs = logsResponse.data.data || [];
      const nextPagination = logsResponse.data.pagination || {
        total: 0,
        limit: 50,
      };
      const nextOptions = optionsResponse.data.data || {
        actions: [],
        entityTypes: [],
        users: [],
      };
      setLogs((previous) =>
        sameRows(previous, nextLogs) ? previous : nextLogs,
      );
      setPagination((previous) =>
        previous.total === nextPagination.total &&
        previous.limit === nextPagination.limit
          ? previous
          : nextPagination,
      );
      setOptions((previous) =>
        JSON.stringify(previous) === JSON.stringify(nextOptions)
          ? previous
          : nextOptions,
      );
      hasLoadedLogs.current = true;
    } catch (errorResponse) {
      toast.error(
        errorResponse.response?.data?.Error || "Could not load audit records",
      );
    } finally {
      setLoading(false);
    }
  }, [authorised, filters, page]);

  const refreshOverview = useCallback(async () => {
    if (!authorised) return;
    try {
      const { data } = await axios.get(`${API_URL}/audit/overview`);
      if (data.Status) {
        const nextOverview = data.data || emptyOverview;
        setOverview(nextOverview);
        setPerformanceHistory((current) =>
          [
            ...current,
            {
              sample: current.length + 1,
              cpu: Number(nextOverview.performance?.cpuPercent || 0),
              memory: Number(nextOverview.performance?.memoryPercent || 0),
              heap: getHeapPercent(nextOverview.performance),
            },
          ].slice(-60),
        );
        setLive(true);
      }
    } catch {
      setLive(false);
    }
  }, [authorised]);

  useEffect(() => {
    load();
  }, [load]);
  useEffect(() => {
    if (!authorised) return undefined;
    const interval = window.setInterval(load, 10000);
    return () => window.clearInterval(interval);
  }, [authorised, load]);
  useEffect(() => {
    refreshOverview();
    const interval = window.setInterval(refreshOverview, 1000);
    return () => window.clearInterval(interval);
  }, [refreshOverview]);

  const logout = async () => {
    try {
      await axios.post(`${API_URL}/auth/logout`);
    } finally {
      navigate("/login", { replace: true });
    }
  };

  if (authorised === null)
    return (
      <div className="flex min-h-svh items-center justify-center">
        <RefreshCw className="h-6 w-6 animate-spin text-muted-foreground" />
      </div>
    );
  if (!authorised)
    return (
      <div className="flex min-h-svh items-center justify-center bg-muted/30 p-5">
        <div className="max-w-md rounded-xl border bg-background p-8 text-center space-y-4 shadow-sm">
          <ShieldCheck className="mx-auto h-10 w-10 text-rose-600" />
          <h1 className="text-xl font-bold">Auditor access required</h1>
          <p className="text-sm text-muted-foreground">
            This independent audit portal is available only to accounts with the
            auditor role.
          </p>
          <Button onClick={() => navigate("/login", { replace: true })}>
            Go to Login
          </Button>
        </div>
      </div>
    );

  const pages = Math.max(Math.ceil(pagination.total / pagination.limit), 1);
  const update = (key, value) => {
    setPage(1);
    setFilters((current) => ({ ...current, [key]: value }));
  };
  const maxActionCount = Math.max(
    ...overview.actions.map((item) => Number(item.count)),
    1,
  );

  return (
    <main className="min-h-svh bg-muted/30 p-5 md:p-8">
      <div className="mx-auto max-w-7xl space-y-5">
        <header className="flex flex-wrap items-center justify-between gap-4 rounded-xl border bg-background px-5 py-4 shadow-sm">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-slate-900 text-white">
              <FileSearch className="h-5 w-5" />
            </div>
            <div>
              <h1 className="font-bold">Audit Portal</h1>
              <p className="text-xs text-muted-foreground">
                Read-only activity record · Auditor access
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Badge variant={live ? "default" : "secondary"} className="gap-1.5">
              <span
                className={`h-1.5 w-1.5 rounded-full ${live ? "bg-emerald-300" : "bg-muted-foreground"}`}
              />{" "}
              {live ? "Live" : "Offline"}
            </Badge>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                load();
                refreshOverview();
              }}
              className="gap-1.5"
            >
              <RefreshCw className="h-3.5 w-3.5" /> Refresh
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={logout}
              className="gap-1.5"
            >
              <LogOut className="h-3.5 w-3.5" /> Sign out
            </Button>
          </div>
        </header>

        <section className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
          {[
            [
              "Total events",
              overview.summary.total,
              FileSearch,
              "all recorded activity",
            ],
            [
              "Last 24 hours",
              overview.summary.last_24_hours,
              Activity,
              "recent activity",
            ],
            [
              "Last hour",
              overview.summary.last_hour,
              Zap,
              "near real-time pulse",
            ],
            ["Active actors", overview.summary.actors, Users, "unique users"],
            [
              "Entity types",
              overview.summary.entities,
              BarChart3,
              "tracked surfaces",
            ],
          ].map(([label, value, Icon, note]) => (
            <div
              key={label}
              className="rounded-xl border bg-background p-4 shadow-sm"
            >
              <div className="flex items-start justify-between">
                <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  {label}
                </p>
                <Icon className="h-4 w-4 text-primary" />
              </div>
              <p className="mt-2 text-2xl font-bold tabular-nums">
                {Number(value || 0).toLocaleString()}
              </p>
              <p className="mt-1 text-xs text-muted-foreground">{note}</p>
            </div>
          ))}
        </section>

        <section className="grid gap-5 lg:grid-cols-[1.1fr_0.9fr]">
          <div className="rounded-xl border bg-background p-5 shadow-sm">
            <div className="mb-4 flex items-center justify-between">
              <div>
                <h2 className="font-semibold">Activity pulse</h2>
                <p className="text-xs text-muted-foreground">
                  Events grouped by hour · updates every 10 seconds
                </p>
              </div>
              <Badge variant="outline">24h</Badge>
            </div>
            <div className="relative h-40 min-w-0 border-b border-l px-2">
              {overview.hourly.length === 0 ? (
                <p className="pt-14 text-center text-xs text-muted-foreground">
                  No activity in the last 24 hours.
                </p>
              ) : (
                <ChartContainer
                  config={activityChartConfig}
                  className="h-full min-h-0 min-w-0 w-full aspect-auto"
                >
                  <LineChart
                    accessibilityLayer
                    data={overview.hourly}
                    margin={{ left: 8, right: 8, top: 10, bottom: 0 }}
                  >
                    <CartesianGrid vertical={false} />
                    <XAxis
                      dataKey="hour"
                      tickLine={false}
                      axisLine={false}
                      tickMargin={8}
                      tickFormatter={(value) => value.slice(0, 2)}
                    />
                    <ChartTooltip
                      cursor={false}
                      content={<ChartTooltipContent />}
                    />
                    <Line
                      dataKey="count"
                      name="events"
                      type="monotone"
                      stroke="var(--color-events)"
                      strokeWidth={2}
                      dot={false}
                      activeDot={{ r: 4 }}
                    />
                  </LineChart>
                </ChartContainer>
              )}
            </div>
          </div>
          <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-1">
            <div className="rounded-xl border bg-background p-5 shadow-sm">
              <h2 className="font-semibold">Top actions</h2>
              <div className="mt-4 space-y-3">
                {overview.actions.slice(0, 5).map((item) => (
                  <div key={item.action}>
                    <div className="mb-1 flex justify-between gap-3 text-xs">
                      <span className="truncate">{item.action}</span>
                      <span className="font-semibold">{item.count}</span>
                    </div>
                    <div className="h-1.5 rounded-full bg-muted">
                      <div
                        className="h-full rounded-full bg-primary"
                        style={{
                          width: `${(Number(item.count) / maxActionCount) * 100}%`,
                        }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="rounded-xl border bg-background p-5 shadow-sm">
              <h2 className="font-semibold">Tracked entities</h2>
              <div className="mt-4 space-y-2">
                {overview.entities.slice(0, 5).map((item) => (
                  <div
                    key={item.entity_type}
                    className="flex items-center justify-between rounded-md bg-muted/40 px-3 py-2 text-xs"
                  >
                    <span>{pretty(item.entity_type)}</span>
                    <Badge variant="secondary">{item.count}</Badge>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section className="overflow-hidden rounded-xl border bg-background shadow-sm">
          <div className="flex flex-wrap items-center justify-between gap-3 border-b px-5 py-4">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary">
                <Server className="h-5 w-5" />
              </div>
              <div>
                <h2 className="font-semibold">Server Task Manager</h2>
                <p className="text-xs text-muted-foreground">
                  Performance · Processes · Details
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2 text-xs">
              <span
                className={`h-2 w-2 rounded-full ${live ? "bg-emerald-500" : "bg-slate-400"}`}
              />
              <span className="text-muted-foreground">
                {live ? "Updating every second" : "Waiting for server"}
              </span>
              <Badge variant="outline">
                {overview.performance?.platform || "—"}
              </Badge>
            </div>
          </div>
          <div className="grid lg:grid-cols-[190px_minmax(0,1fr)]">
            <aside className="border-b bg-muted/20 p-3 lg:border-b-0 lg:border-r">
              <p className="mb-2 px-2 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                Resources
              </p>
              {[
                [
                  "CPU",
                  Cpu,
                  Number(overview.performance?.cpuPercent || 0),
                  "sky",
                ],
                [
                  "Memory",
                  HardDrive,
                  Number(overview.performance?.memoryPercent || 0),
                  "amber",
                ],
                [
                  "Node heap",
                  Gauge,
                  getHeapPercent(overview.performance),
                  "emerald",
                ],
              ].map(([label, Icon, value, tone]) => (
                <div
                  key={label}
                  className="mb-2 rounded-md border bg-background px-3 py-2.5"
                >
                  <div className="flex items-center gap-2">
                    <Icon className="h-4 w-4 text-muted-foreground" />
                    <span className="text-sm font-medium">{label}</span>
                  </div>
                  <div className="mt-2 flex items-end justify-between">
                    <span className="font-mono text-lg font-semibold tabular-nums">
                      {value.toFixed(1)}%
                    </span>
                    <span
                      className={`h-1.5 w-1.5 rounded-full ${
                        tone === "sky"
                          ? "bg-sky-500"
                          : tone === "amber"
                            ? "bg-amber-500"
                            : "bg-emerald-500"
                      }`}
                    />
                  </div>
                </div>
              ))}
            </aside>
            <div className="min-w-0 p-4">
              <div className="grid gap-3 md:grid-cols-3">
                <ResourceGraph
                  title="CPU usage"
                  value={Number(overview.performance?.cpuPercent || 0)}
                  color="#0ea5e9"
                  data={performanceHistory}
                  dataKey="cpu"
                />
                <ResourceGraph
                  title="System memory"
                  value={Number(overview.performance?.memoryPercent || 0)}
                  color="#f59e0b"
                  data={performanceHistory}
                  dataKey="memory"
                />
                <ResourceGraph
                  title="Node heap"
                  value={getHeapPercent(overview.performance)}
                  color="#10b981"
                  data={performanceHistory}
                  dataKey="heap"
                />
              </div>
              <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
                {[
                  [
                    "DB latency",
                    `${overview.performance?.dbLatencyMs || 0} ms`,
                  ],
                  [
                    "Uptime",
                    `${Math.floor((overview.performance?.uptimeSeconds || 0) / 3600)}h ${Math.floor(((overview.performance?.uptimeSeconds || 0) % 3600) / 60)}m`,
                  ],
                  [
                    "RSS memory",
                    `${overview.performance?.memoryRssMb || 0} MB`,
                  ],
                  [
                    "Heap",
                    `${overview.performance?.heapUsedMb || 0} / ${overview.performance?.heapTotalMb || 0} MB`,
                  ],
                  [
                    "Free memory",
                    `${overview.performance?.freeMemoryMb || 0} MB`,
                  ],
                  ["CPU cores", overview.performance?.cpuCount || "—"],
                  [
                    "Load average",
                    Number(overview.performance?.loadAverage || 0).toFixed(2),
                  ],
                  ["Process ID", overview.performance?.pid || "—"],
                ].map(([label, value]) => (
                  <div
                    key={label}
                    className="rounded-md bg-muted/40 px-3 py-2.5"
                  >
                    <p className="text-[11px] text-muted-foreground">{label}</p>
                    <p className="mt-1 font-mono text-sm font-semibold tabular-nums">
                      {value}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section className="grid gap-3 rounded-xl border bg-background p-4 md:grid-cols-5">
          <div className="space-y-1">
            <Label className="text-xs">Action</Label>
            <Select
              value={filters.action}
              onValueChange={(value) => update("action", value)}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All actions</SelectItem>
                {options.actions.map((item) => (
                  <SelectItem key={item.action} value={item.action}>
                    {item.action}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <Label className="text-xs">Entity</Label>
            <Select
              value={filters.entityType}
              onValueChange={(value) => update("entityType", value)}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All entities</SelectItem>
                {options.entityTypes.map((item) => (
                  <SelectItem key={item.entity_type} value={item.entity_type}>
                    {pretty(item.entity_type)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <Label className="text-xs">Actor</Label>
            <Select
              value={filters.userId}
              onValueChange={(value) => update("userId", value)}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All actors</SelectItem>
                {options.users.map((user) => (
                  <SelectItem key={user.id} value={String(user.id)}>
                    {user.full_name} ({user.username})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <Label className="text-xs">From</Label>
            <Input
              type="date"
              value={filters.from}
              onChange={(event) => update("from", event.target.value)}
            />
          </div>
          <div className="space-y-1">
            <Label className="text-xs">To</Label>
            <Input
              type="date"
              value={filters.to}
              onChange={(event) => update("to", event.target.value)}
            />
          </div>
        </section>

        <section className="overflow-hidden rounded-xl border bg-background shadow-sm">
          <div className="border-b px-5 py-3 text-sm text-muted-foreground">
            {pagination.total} record{pagination.total === 1 ? "" : "s"}
          </div>
          {loading ? (
            <div className="flex justify-center py-20">
              <RefreshCw className="h-6 w-6 animate-spin text-muted-foreground" />
            </div>
          ) : logs.length === 0 ? (
            <div className="py-20 text-center text-sm text-muted-foreground">
              No activity matches these filters.
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[950px] text-sm">
                <thead className="border-b bg-muted/40 text-left text-xs uppercase tracking-wider text-muted-foreground">
                  <tr>
                    <th className="px-4 py-3 font-medium">Time</th>
                    <th className="px-4 py-3 font-medium">Actor</th>
                    <th className="px-4 py-3 font-medium">Action</th>
                    <th className="px-4 py-3 font-medium">Entity</th>
                    <th className="px-4 py-3 font-medium">Details</th>
                    <th className="px-4 py-3 font-medium">IP</th>
                  </tr>
                </thead>
                <tbody>
                  {logs.map((log) => (
                    <AuditLogRow key={log.id} log={log} />
                  ))}
                </tbody>
              </table>
            </div>
          )}
          <div className="flex items-center justify-between border-t px-5 py-3">
            <p className="text-xs text-muted-foreground">
              Page {page} of {pages}
            </p>
            <div className="flex gap-2">
              <Button
                size="sm"
                variant="outline"
                disabled={page === 1}
                onClick={() => setPage((current) => current - 1)}
              >
                Previous
              </Button>
              <Button
                size="sm"
                variant="outline"
                disabled={page >= pages}
                onClick={() => setPage((current) => current + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
