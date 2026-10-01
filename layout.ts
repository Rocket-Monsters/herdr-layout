// Applies <worktree>/.herdr-layout.yml to a new worktree workspace.
// Falls back to the main checkout's copy (branches older than the file). No file = no-op.
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

type Pane = { split?: "right" | "down"; of?: number; ratio?: number; command?: string };

const herdr = process.env.HERDR_BIN_PATH ?? "herdr";
const run = (...args: string[]) => {
  const r = Bun.spawnSync([herdr, ...args]);
  if (!r.success) throw new Error(`herdr ${args.join(" ")}: ${r.stderr.toString()}`);
  return JSON.parse(r.stdout.toString() || "null");
};

const raw = process.env.HERDR_PLUGIN_EVENT_JSON ?? "";
console.error(`event: ${raw}`);
const data = JSON.parse(raw || "{}").data ?? {};

const ws: string | undefined = data.workspace?.workspace_id;
if (!ws) { console.error("no workspace_id in event"); process.exit(1); }

const layout = [data.worktree?.path, data.workspace?.worktree?.repo_root]
  .filter(Boolean)
  .map((dir: string) => join(dir, ".herdr-layout.yml"))
  .find(existsSync);
if (!layout) { console.error("no .herdr-layout.yml, skipping"); process.exit(0); }
console.error(`layout: ${layout}`);

const panes: Pane[] = Bun.YAML.parse(readFileSync(layout, "utf8"))?.panes ?? [];
const ids: string[] = [run("pane", "list", "--workspace", ws).result.panes[0].pane_id];

panes.forEach((p, i) => {
  if (i > 0) {
    const args = ["pane", "split", ids[p.of ?? i - 1], "--direction", p.split ?? "right", "--no-focus"];
    if (p.ratio != null) args.push("--ratio", String(p.ratio));
    ids[i] = run(...args).result.pane.pane_id;
  }
  if (p.command) run("pane", "run", ids[i], p.command);
});
