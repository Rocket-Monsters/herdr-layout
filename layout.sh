#!/usr/bin/env bash
# Applies <worktree>/.herdr-layout.yml to a new worktree workspace.
# Falls back to the main checkout's copy (branches older than the file). No file = no-op.
set -euo pipefail
h="${HERDR_BIN_PATH:-herdr}"
ev="${HERDR_PLUGIN_EVENT_JSON:-}"
echo "event: $ev" >&2

ws=$(jq -r '.data.workspace.workspace_id // empty' <<<"$ev")
[ -n "$ws" ] || { echo "no workspace_id in event" >&2; exit 1; }

layout=""
for dir in "$(jq -r '.data.worktree.path // empty' <<<"$ev")" \
           "$(jq -r '.data.workspace.worktree.repo_root // empty' <<<"$ev")"; do
  [ -n "$dir" ] && [ -f "$dir/.herdr-layout.yml" ] && { layout="$dir/.herdr-layout.yml"; break; }
done
[ -n "$layout" ] || { echo "no .herdr-layout.yml, skipping" >&2; exit 0; }
echo "layout: $layout" >&2

spec=$(yq -o=json '.panes // []' "$layout")
ids=("$("$h" pane list --workspace "$ws" | jq -r '[.. | objects | .pane_id? // empty] | first')")

n=$(jq length <<<"$spec")
for ((i = 0; i < n; i++)); do
  p=$(jq ".[$i]" <<<"$spec")
  if ((i > 0)); then
    of=$(jq -r ".of // $((i - 1))" <<<"$p")
    args=(--direction "$(jq -r '.split // "right"' <<<"$p")" --no-focus)
    ratio=$(jq -r '.ratio // empty' <<<"$p")
    [ -n "$ratio" ] && args+=(--ratio "$ratio")
    ids[i]=$("$h" pane split "${ids[of]}" "${args[@]}" | jq -r '.result.pane.pane_id')
  fi
  cmd=$(jq -r '.command // empty' <<<"$p")
  [ -z "$cmd" ] || "$h" pane run "${ids[i]}" "$cmd"
done
