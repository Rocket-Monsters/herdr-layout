# Applies <worktree>/.herdr-layout to a new worktree workspace (Windows).
# Falls back to the main checkout's copy (branches older than the file). No file = no-op.
# Keep in sync with layout.sh. Written for Windows PowerShell 5.1 (built into Windows).
$ErrorActionPreference = 'Stop'
$h = if ($env:HERDR_BIN_PATH) { $env:HERDR_BIN_PATH } else { 'herdr' }
$raw = $env:HERDR_PLUGIN_EVENT_JSON
[Console]::Error.WriteLine("event: $raw")

function Invoke-Herdr {
  $out = & $h @args
  if ($LASTEXITCODE) { throw "herdr $args failed (exit $LASTEXITCODE)" }
  if ($out) { ($out -join "`n") | ConvertFrom-Json }
}

$data = if ($raw) { ($raw | ConvertFrom-Json).data } else { $null }
$ws = $data.workspace.workspace_id
if (-not $ws) { [Console]::Error.WriteLine('no workspace_id in event'); exit 1 }

$layout = @($data.worktree.path, $data.workspace.worktree.repo_root) |
  Where-Object { $_ } |
  ForEach-Object { Join-Path $_ '.herdr-layout' } |
  Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
  Select-Object -First 1
if (-not $layout) { [Console]::Error.WriteLine('no .herdr-layout, skipping'); exit 0 }
[Console]::Error.WriteLine("layout: $layout")

$ids = @{ 0 = (Invoke-Herdr pane list --workspace $ws).result.panes[0].pane_id }
$i = 0
foreach ($line in Get-Content -LiteralPath $layout) {
  $line = $line.Trim()
  if (-not $line -or $line.StartsWith('#')) { continue }
  $split, $of, $ratio, $cmd = $line -split '\s+', 4
  if ($i -gt 0) {
    $src = if ($of -and $of -ne '-') { [int]$of } else { $i - 1 }
    $dir = if ($split -ne '-') { $split } else { 'right' }
    $a = @('pane', 'split', $ids[$src], '--direction', $dir, '--no-focus')
    if ($ratio -and $ratio -ne '-') { $a += '--ratio', $ratio }
    $ids[$i] = (Invoke-Herdr @a).result.pane.pane_id
  }
  if ($cmd -and $cmd -ne '-') { Invoke-Herdr pane run $ids[$i] $cmd | Out-Null }
  $i++
}
