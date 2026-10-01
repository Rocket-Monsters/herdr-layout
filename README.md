# herdr-layout

A [herdr](https://herdr.dev) plugin that lays out a new worktree workspace from a
`.herdr-layout.yml` file in the project.

It runs on herdr's `worktree.created` event. There is no default layout: if the project has
no `.herdr-layout.yml`, the plugin does nothing. Plain workspaces (not worktrees) are left alone.

## Requirements

Works on macOS, Linux and Windows.

- herdr ≥ 0.9.0
- [Bun](https://bun.sh) on `PATH` (it parses the YAML; no other dependencies)
- whatever your layout's `command`s run (e.g. `lazygit`)

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

Add `.herdr-layout.yml` to the project root and commit it. The plugin looks for it in:

1. the new worktree's checkout (so each branch can carry its own layout), then
2. the repo's main checkout (so branches created before the file existed still get it).

If neither has the file, nothing happens.

```yaml
# Two shells stacked left, lazygit right.
#
#   ┌──────────┬──────────┐
#   │  shell   │          │
#   ├──────────┤ lazygit  │
#   │  shell   │          │
#   └──────────┴──────────┘
panes:
  - {}                # 0: the workspace's initial pane
  - split: right      # 1
    of: 0
    command: lazygit
  - split: down       # 2
    of: 0
```

`panes` is a list, applied in order. The first entry is the pane herdr already opened;
every later entry is created by splitting an earlier one.

| Key | Applies to | Default | Meaning |
|-----|-----------|---------|---------|
| `split` | panes 1+ | `right` | `right` or `down` |
| `of` | panes 1+ | previous pane | index of the pane to split |
| `ratio` | panes 1+ | herdr's default | size of the split, e.g. `0.3` |
| `command` | any pane | none (plain shell) | command to run in the pane |

Order matters: in the example, splitting pane 0 right first makes two columns, then splitting
pane 0 down stacks the left column.

The event the plugin reacts to is set in [`herdr-plugin.toml`](herdr-plugin.toml) under `[[events]]`.

### Copying gitignored dev files into new worktrees

That's not this plugin's job. Do it in the repo with a git `post-checkout` hook, so it
works for every tool that creates worktrees, not only herdr. See `.worktreeinclude` and
`scripts/worktree-setup.sh` in `rm-heimdall` for a working example.

## Troubleshooting

If a new worktree opens without the layout, read the plugin's command logs:

```sh
herdr plugin log list
```

`layout.ts` logs the event JSON herdr sent and which layout file it used.

- `no .herdr-layout.yml, skipping`: no layout file in the worktree or the main checkout.
- `no workspace_id in event`: the event payload changed shape.
