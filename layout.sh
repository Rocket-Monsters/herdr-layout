#!/usr/bin/env bash
set -euo pipefail
h="${HERDR_BIN_PATH:-herdr}"
ev="${HERDR_PLUGIN_EVENT_JSON:-}"
echo "event: $ev" >&2


ws=$(jq -r '[.. | objects | .workspace_id? // empty] | first // empty' <<<"$ev")
[ -n "$ws" ] || { echo "no workspace_id in event" >&2; exit 1; }
root=$("$h" pane list --workspace "$ws" | jq -r '[.. | objects | .pane_id? // empty] | first')

right=$("$h" pane split "$root" --direction right --no-focus | jq -r '.result.pane.pane_id')
"$h" pane split "$root" --direction down --no-focus >/dev/null
"$h" pane run "$right" lazygit
