# herdr-layout

A [herdr](https://herdr.dev) plugin that lays out every new worktree workspace:

```
┌──────────┬──────────┐
│  shell   │          │
├──────────┤ lazygit  │
│  shell   │          │
└──────────┴──────────┘
```

It runs on herdr's `worktree.created` event. Plain workspaces (not worktrees) are left alone.

## Requirements

- herdr ≥ 0.9.0 (macOS)
- [`jq`](https://jqlang.org) and [`lazygit`](https://github.com/jesseduffield/lazygit) on `PATH`

```sh
brew install jq lazygit
```

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

The plugin has no config file. The layout lives in [`layout.sh`](layout.sh): it splits the
workspace's first pane right (running `lazygit`), then splits the first pane down. To change
it, edit `layout.sh` in a linked clone; the `herdr pane split` / `herdr pane run` calls are the
whole layout.

The event it reacts to is set in [`herdr-plugin.toml`](herdr-plugin.toml) under `[[events]]`.

### Copying gitignored dev files into new worktrees

That's not this plugin's job. Do it in the repo with a git `post-checkout` hook, so it
works for every tool that creates worktrees, not only herdr. See `.worktreeinclude` and
`scripts/worktree-setup.sh` in `rm-heimdall` for a working example.

## Troubleshooting

If a new worktree opens without the layout, read the plugin's command logs:

```sh
herdr plugin log list
```

`layout.sh` prints the event JSON it received to stderr, so the log shows what herdr sent.
"no workspace_id in event" means the event payload changed shape.
