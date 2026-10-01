# herdr-layout

A [herdr](https://herdr.dev) plugin that lays out a new worktree workspace from a
`.herdr-layout` file in the project.

It runs on herdr's `worktree.created` event. There is no default layout: if the project has
no `.herdr-layout`, the plugin does nothing. Plain workspaces (not worktrees) are left alone.

## Requirements

Works on macOS, Linux and Windows.

- herdr ≥ 0.9.0
- whatever your layout's commands run (e.g. `lazygit`)

Nothing else to install. Linux and macOS run [`layout.sh`](layout.sh) with the system `sh`;
Windows runs [`layout.ps1`](layout.ps1) with the built-in Windows PowerShell.

## Install

From GitHub (the repo is private, so `git` must be able to clone it; `gh auth setup-git` is enough):

```sh
herdr plugin install Rocket-Monsters/herdr-layout
```

Or link a local clone, so edits apply without reinstalling:

```sh
git clone https://github.com/Rocket-Monsters/herdr-layout.git
herdr plugin link ./herdr-layout
```

Check it's registered and enabled:

```sh
herdr plugin list
```

## Update / uninstall

herdr has no `plugin update`; reinstall to pull the latest:

```sh
herdr plugin uninstall rocket-monsters.herdr-layout
herdr plugin install Rocket-Monsters/herdr-layout
```

A linked clone only needs `git pull`. To remove a linked clone: `herdr plugin unlink rocket-monsters.herdr-layout`.

Enable or disable without uninstalling:

```sh
herdr plugin disable rocket-monsters.herdr-layout
herdr plugin enable rocket-monsters.herdr-layout
```

## Configuration

Add `.herdr-layout` to the project root and commit it. The plugin looks for it in:

1. the new worktree's checkout (so each branch can carry its own layout), then
2. the repo's main checkout (so branches created before the file existed still get it).

If neither has the file, nothing happens.

```
# Two shells stacked left, lazygit right.
#
#   ┌──────────┬──────────┐
#   │  shell   │          │
#   ├──────────┤ lazygit  │
#   │  shell   │          │
#   └──────────┴──────────┘
#
# split  of  ratio  command
-        -   -      -
right    0   -      lazygit
down     0   -      -
```

One pane per line, applied in order. Columns are separated by spaces; `-` means "use the
default". Blank lines and lines starting with `#` are ignored. The first pane line is the pane
herdr already opened (its `split`, `of` and `ratio` are ignored); every later line creates a
pane by splitting an earlier one.

| Column | Default | Meaning |
|--------|---------|---------|
| `split` | `right` | `right` or `down` |
| `of` | previous pane | number of the pane to split (the first pane line is `0`) |
| `ratio` | herdr's default | size of the split, e.g. `0.3` |
| `command` | none (plain shell) | command to run in the pane; the rest of the line, so it may contain spaces |

Order matters: in the example, splitting pane 0 right first makes two columns, then splitting
pane 0 down stacks the left column.

The event the plugin reacts to is set in [`herdr-plugin.toml`](herdr-plugin.toml) under `[[events]]`
(one entry per platform).

## Contributing

`layout.sh` and `layout.ps1` implement the same behavior; a change to one needs the same change
in the other. `layout.sh` sticks to POSIX `sh` (it runs under `dash` on Debian/Ubuntu) and reads
herdr's JSON with `grep`, so it needs no extra tools. `layout.ps1` targets Windows PowerShell 5.1.

### Copying gitignored dev files into new worktrees

That's not this plugin's job. Do it in the repo with a git `post-checkout` hook, so it
works for every tool that creates worktrees, not only herdr. See `.worktreeinclude` and
`scripts/worktree-setup.sh` in `rm-heimdall` for a working example.

## Troubleshooting

If a new worktree opens without the layout, read the plugin's command logs:

```sh
herdr plugin log list
```

`layout.sh` / `layout.ps1` log the event JSON herdr sent and which layout file it used.

- `no .herdr-layout, skipping`: no layout file in the worktree or the main checkout.
- `no workspace_id in event`: the event payload changed shape.
