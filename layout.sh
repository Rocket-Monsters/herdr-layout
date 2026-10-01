#!/bin/sh
# Applies <worktree>/.herdr-layout to a new worktree workspace (Linux/macOS).
# Falls back to the main checkout's copy (branches older than the file). No file = no-op.
# Keep in sync with layout.ps1.
set -eu
h="${HERDR_BIN_PATH:-herdr}"
ev="${HERDR_PLUGIN_EVENT_JSON:-}"
echo "event: $ev" >&2

# First value of a JSON string field. herdr prints compact JSON, and every field read here
# is a plain string, so no JSON parser is needed.
field() { printf '%s' "$2" | grep -o "\"$1\":\"[^\"]*\"" | head -n 1 | cut -d '"' -f 4; }

ws=$(field workspace_id "$ev")
[ -n "$ws" ] || { echo "no workspace_id in event" >&2; exit 1; }

layout=""
for dir in "$(field path "$ev")" "$(field repo_root "$ev")"; do
  if [ -n "$dir" ] && [ -f "$dir/.herdr-layout" ]; then layout="$dir/.herdr-layout"; break; fi
done
[ -n "$layout" ] || { echo "no .herdr-layout, skipping" >&2; exit 0; }
echo "layout: $layout" >&2

id_0=$(field pane_id "$("$h" pane list --workspace "$ws")")
i=0
tr -d '\r' < "$layout" | while read -r split of ratio cmd || [ -n "$split" ]; do
  case "$split" in '' | '#'*) continue ;; esac
  if [ "$i" -gt 0 ]; then
    [ "$of" != - ] && [ -n "$of" ] || of=$((i - 1))
    [ "$split" != - ] || split=right
    eval "src=\$id_$of"
    if [ "$ratio" != - ] && [ -n "$ratio" ]; then
      out=$("$h" pane split "$src" --direction "$split" --ratio "$ratio" --no-focus </dev/null)
    else
      out=$("$h" pane split "$src" --direction "$split" --no-focus </dev/null)
    fi
    eval "id_$i=\$(field pane_id \"\$out\")"
  fi
  if [ "$cmd" != - ] && [ -n "$cmd" ]; then
    eval "\"\$h\" pane run \"\$id_$i\" \"\$cmd\"" >/dev/null </dev/null
  fi
  i=$((i + 1))
done
