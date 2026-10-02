# herdr-layout

A [herdr](https://herdr.dev) plugin that opens every new worktree with your panes already
split and your commands already running.

```
┌──────────┬──────────┐
│  claude  │          │
├──────────┤ lazygit  │
│  shell   │          │
└──────────┴──────────┘
```

Works on macOS, Linux and Windows with nothing extra to install.

## Quick start

1. Install the plugin:

   ```sh
   herdr plugin install Rocket-Monsters/herdr-layout
   ```

2. Add a file named `.herdr-layout` to the root of your project:

   ```
   -      -  -  claude
   right  0  -  lazygit
   down   0  -  -
   ```

3. Create a worktree in herdr. It opens with the layout above.

Commit `.herdr-layout` so everyone on the project gets the same layout. More layouts are in
[`examples.herdr-layout`](examples.herdr-layout).

## The format

One line per pane. The first line is the pane herdr already opened (pane `0`); each line after
it splits an earlier pane to make a new one (pane `1`, `2`, ...).

```
split  of  ratio  command
```

| Column | Meaning | `-` means |
|--------|---------|-----------|
| `split` | `right` or `down` | `right` |
| `of` | Number of the pane to split | the pane on the line above |
| `ratio` | Share the split pane **keeps**, `0` to `1` | an even split |
| `command` | What to run, to the end of the line | a plain shell |

On the first line only `command` counts. Lines starting with `#` and blank lines are ignored.

Line order matters. In the quick start example, splitting pane `0` right first makes two
columns, then splitting pane `0` down stacks the left one. Swap those two lines and you get
two panes on top and one full-width pane below.

### Setup steps

A line starting with `run` runs a command once in the new worktree instead of making a pane:

```
run    npm install
-      -  -  claude
right  0  -  npm run dev
```

`run` lines don't get a pane number. Steps run in order; a failed step is logged and the layout
carries on. On Windows they run in PowerShell.

### Where the file is read from

The new worktree first, then the project's main checkout, so branches made before you added
the file still get the layout. If neither has it, the plugin does nothing.

## Requirements

- herdr 0.9.0 or newer
- The programs your layout runs (`claude`, `lazygit`, ...)

## Managing the plugin

| To | Run |
|----|-----|
| Install | `herdr plugin install Rocket-Monsters/herdr-layout` |
| Update | `herdr plugin uninstall rocket-monsters.herdr-layout`, then install again |
| Disable / enable | `herdr plugin disable rocket-monsters.herdr-layout` / `enable` |
| Remove | `herdr plugin uninstall rocket-monsters.herdr-layout` |

## Troubleshooting

Check the log with `herdr plugin log list`. It shows which layout file was used, or:

- `no .herdr-layout, skipping`: no file found. The name starts with a dot and has no extension.
- `no workspace_id in event`: unexpected event from herdr. Please open an issue with the log.

If a pane opens but its command doesn't start, make sure the program is on your `PATH`.

The plugin only runs when herdr creates a **worktree**, not a plain workspace.

## Contributing

[`layout.sh`](layout.sh) (macOS/Linux, plain POSIX `sh`) and [`layout.ps1`](layout.ps1)
(Windows PowerShell 5.1) do the same job, so a change to one needs the same change in the other.
Neither may depend on extra tools such as `jq`.

To test locally:

```sh
git clone https://github.com/Rocket-Monsters/herdr-layout.git
herdr plugin link ./herdr-layout
```

## License

[MIT](LICENSE)
