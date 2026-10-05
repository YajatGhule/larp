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

```sh
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

The script automatically:
- Detects your distro and installs dependencies (apt, dnf, zypper, xbps)
- Downloads and installs `pipes.sh` and `hypr-layout`
- Puts `larp` and `larp-ws` in `~/.local/bin`

On x86_64 with glibc 2.39+, it uses the prebuilt `hypr-layout` binary. On older systems, it builds from source with cargo.

**See [INSTALL.md](INSTALL.md) for detailed setup by distro, troubleshooting, and advanced options.**

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
