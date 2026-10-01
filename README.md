# herdr-layout

Open every new [herdr](https://herdr.dev) worktree with your panes already set up.

Put a small `.herdr-layout` file in your project, and each time herdr creates a worktree for
it, the plugin splits the panes and starts your commands for you:

```
┌──────────┬──────────┐
│  shell   │          │
├──────────┤ lazygit  │
│  shell   │          │
└──────────┴──────────┘
```

- **Works everywhere:** macOS, Linux and Windows.
- **Nothing to install:** it uses the shell your system already has.
- **Per project:** each project decides its own layout. No file, no change.

## Quick start

**1. Install the plugin**

```sh
herdr plugin install Rocket-Monsters/herdr-layout
```

**2. Add a `.herdr-layout` file to the root of your project**

```
# split  of  ratio  command
-        -   -      -
right    0   -      lazygit
down     0   -      -
```

**3. Create a worktree in herdr.** It opens with the layout above. Commit the file so
everyone on the project gets the same layout.

## Writing a layout

Each line describes one pane. The first line is the pane herdr already opened, and each line
after it adds a new pane by splitting one of the panes before it.

A line has four columns, separated by spaces:

| Column | What it means | If you write `-` |
|--------|---------------|------------------|
| `split` | Where the new pane goes: `right` or `down` | `right` |
| `of` | Which pane to split, by number. The first line is pane `0`, the next is `1`, and so on | the pane on the line above |
| `ratio` | How much space the pane being split **keeps**, from `0` to `1`. The new pane gets the rest | an even split |
| `command` | What to run in the new pane. Everything to the end of the line, spaces included | a plain shell |

On the first line, only `command` is used; write `-` for the other three.

Lines starting with `#` are comments, and blank lines are ignored.

### Examples

**Two panes side by side**

```
-      -  -  -
right  -  -  -
```

**Editor on top, small terminal at the bottom** (the editor keeps 70%)

```
-     -  -    nvim
down  0  0.7  -
```

**Two shells stacked left, lazygit right**

```
-      -  -  -
right  0  -  lazygit
down   0  -  -
```

Order matters in the last one. Splitting pane `0` to the right first makes two columns; then
splitting pane `0` down stacks the left column. Swap the two lines and you get two panes on
top and one full-width pane at the bottom instead.

### Where the plugin looks for the file

1. In the new worktree, so a branch can carry its own layout.
2. If it isn't there, in the project's main checkout, so branches made before you added the
   file still get the layout.

If neither place has a `.herdr-layout`, the plugin does nothing.

## Requirements

- herdr 0.9.0 or newer
- The programs your layout runs (for example `lazygit`)

That's all. On macOS and Linux the plugin runs with `sh`; on Windows it runs with the
Windows PowerShell that comes with the system.

## Installing, updating and removing

| To... | Run |
|-------|-----|
| Install | `herdr plugin install Rocket-Monsters/herdr-layout` |
| Check it's installed | `herdr plugin list` |
| Update | `herdr plugin uninstall rocket-monsters.herdr-layout`, then install again |
| Turn off for a while | `herdr plugin disable rocket-monsters.herdr-layout` |
| Turn back on | `herdr plugin enable rocket-monsters.herdr-layout` |
| Remove | `herdr plugin uninstall rocket-monsters.herdr-layout` |

herdr has no update command, which is why updating means reinstalling. Your `.herdr-layout`
files live in your projects, so reinstalling doesn't touch them.

If `install` can't download the repository, check that `git` can reach GitHub from your
machine (for a private copy, run `gh auth setup-git` first).

## Troubleshooting

**A new worktree opened without the layout.** Look at the plugin's log:

```sh
herdr plugin log list
```

The log shows which layout file the plugin used, or one of these messages:

| Message | What it means |
|---------|---------------|
| `no .herdr-layout, skipping` | Neither the worktree nor the main checkout has the file. Check the name: it starts with a dot and has no extension. |
| `no workspace_id in event` | herdr sent an event the plugin doesn't understand. Please open an issue with the log. |

**The panes are there but a command didn't start.** Make sure the program is installed and
on your `PATH`. Try running the command yourself in a herdr pane.

**Plain workspaces don't get the layout.** That's expected: the plugin only runs when herdr
creates a worktree.

## Contributing

Changes are welcome. A few things to know:

- The plugin is two scripts that do the same job: [`layout.sh`](layout.sh) for macOS and Linux,
  and [`layout.ps1`](layout.ps1) for Windows. A change to one needs the same change in the other.
- `layout.sh` must stay plain POSIX `sh` (Debian and Ubuntu run it with `dash`) and must not need
  extra tools such as `jq`.
- `layout.ps1` must work in Windows PowerShell 5.1, the version built into Windows.
- [`herdr-plugin.toml`](herdr-plugin.toml) tells herdr which script to run on which system.

To try a change locally, clone the repo and link it instead of installing:

```sh
git clone https://github.com/Rocket-Monsters/herdr-layout.git
herdr plugin link ./herdr-layout
```

Edits to the scripts take effect on the next worktree you create.

## License

[MIT](LICENSE)
