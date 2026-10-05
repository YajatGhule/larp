# larp

One command that sets up a hacker-style terminal desktop on Hyprland. It opens a 2×2 grid of kitty windows and plays a song in the background:

| | |
|---|---|
| **fastfetch** (system info) | **cmatrix** (falling code) |
| **pipes.sh** (animated pipes) | **cava** (audio visualizer) |

When you run it, it:

1. Raises the system volume smoothly to 70%.
2. Kills anything left over from an earlier run.
3. Plays the song set in your config with `mpv`.
4. Uses `hypr-layout` to open the four panes as tiled kitty windows with a small font.
5. Stops the music when you close the cava pane.

## Install

### Arch (AUR)

```sh
yay -S larp.exe
```

This also installs everything larp needs, including `hypr-layout-bin` and `pipes.sh` from the AUR. To use `larp-ws`, also install `fish`, `jq` and `wtype`.

### Other distros

```sh
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

The script installs the dependencies with apt, dnf, zypper or xbps. It also installs `pipes.sh` and `hypr-layout`, and puts `larp` and `larp-ws` in `~/.local/bin`. The `hypr-layout` binary needs x86_64 and glibc 2.39 or newer. On older systems the script builds it with cargo instead. Options: `--prefix DIR`, `--no-deps`, `--uninstall`.

You need a running [Hyprland](https://hyprland.org/) session.

## Configure

Settings live in `~/.config/larp/config`. Start from [`config.example`](config.example), which the AUR package installs to `/usr/share/doc/larp.exe/`:

```sh
mkdir -p ~/.config/larp
cp config.example ~/.config/larp/config
```

- `AUDIO_PATH`: the song to play. Leave it empty for no music.
- `FONT`: the font size in the panes (default `8.0`).
- `SINK`: the PipeWire sink to play through. Leave it empty to use the default output. List your sinks with `pactl list short sinks`.
- `VOLUME`: the volume to raise the output to (default `70`).

You can also set any of these for a single run, for example `FONT=10 larp`.

## Usage

```sh
larp
```

`larp-ws` is a fish script that runs larp on workspace 10. It closes the window that is there, opens kitty, types `larp`, waits 60 seconds and then goes back to the workspace you were on.

## License

MIT
