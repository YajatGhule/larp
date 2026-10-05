# larp

One command that sets up a hacker-style terminal desktop on Hyprland. It opens a 2×2 grid of kitty windows and plays a song in the background:

| | |
|---|---|
| **fastfetch** (system info) | **cmatrix** (falling code) |
| **pipes.sh** (animated pipes) | **cava** (audio visualizer) |

When you run it, it:

1. Raises the system volume smoothly to 70%.
2. Kills anything left over from an earlier run.
3. Plays the song set in `AUDIO_PATH` with `mpv`.
4. Uses `hypr-layout` to open the four panes as tiled kitty windows with a small font.
5. Stops the music when you close the cava pane.

## Requirements

- [Hyprland](https://hyprland.org/)
- [kitty](https://sw.kovidgoyal.net/kitty/)
- `hypr-layout`
- `fastfetch`, `pipes.sh`, `cmatrix`, `cava`
- `mpv`, `wpctl` (WirePlumber), `pactl`
- For `larp-ws` only: `fish`, `jq`, `wtype`

On Arch:

```sh
sudo pacman -S kitty fastfetch cmatrix cava mpv wireplumber libpulse fish jq wtype
yay -S pipes.sh hypr-layout-bin
```

## Install

```sh
git clone https://github.com/YajatGhule/larp.git
cd larp
ln -s "$PWD/larp" ~/.local/bin/larp
ln -s "$PWD/larp-ws" ~/.local/bin/larp-ws   # optional
```

## Configure

Change these settings at the top of `larp`:

- `AUDIO_PATH`: the song to play.
- `FONT`: the font size in the panes (default `8.0`). You can also set it per run: `FONT=10 larp`.
- `ALC_SINK`: the PipeWire sink to play through. List your sinks with `pactl list short sinks`.

## Usage

```sh
larp
```

`larp-ws` is a fish script that runs larp on workspace 10. It closes the window that is there, opens kitty, types `larp`, waits 60 seconds and then goes back to the workspace you were on.
