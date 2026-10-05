# Installation Guide

## Quick Start

```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
mkdir -p ~/.config/larp
cp config.example ~/.config/larp/config
# Edit the config file and set AUDIO_PATH to your song
nano ~/.config/larp/config
larp
```

## Prerequisites

**Required:**
- [Hyprland](https://hyprland.org/) with a running session
- Linux (x86_64 or any arch with glibc 2.39+)
- `bash` and `curl`

**The script will install these for you, or you can install manually:**
- `kitty` — terminal emulator
- `fastfetch` — system info display
- `cmatrix` — falling matrix rain effect
- `pipes.sh` — animated pipes
- `cava` — audio visualizer
- `wireplumber` and `libpulse` — audio control
- `mpv` — music player (optional, but recommended)

**Optional (for `larp-ws`):**
- `fish` — shell
- `jq` — JSON processor
- `wtype` — text input tool

## Installation by Distro

### Arch Linux

The recommended way is the AUR package (once your account is approved):
```bash
yay -S larp.exe
yay -S fish jq wtype  # for larp-ws
```

Until then, or if the AUR is unavailable:
```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

### Debian / Ubuntu

```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

The script uses `apt` to install packages. If you don't have `sudo` permissions, run with `--no-deps` and install manually:
```bash
sudo apt install kitty fastfetch cmatrix cava mpv wireplumber pulseaudio-utils fish jq wtype pipes.sh
./install.sh --no-deps
```

### Fedora / RHEL / CentOS

```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

The script uses `dnf`. If you prefer manual installation:
```bash
sudo dnf install kitty fastfetch cmatrix cava mpv wireplumber pulseaudio-utils fish jq wtype pipes.sh
./install.sh --no-deps
```

### openSUSE

```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

The script uses `zypper`. Manual:
```bash
sudo zypper install kitty fastfetch cmatrix cava mpv wireplumber pulseaudio-utils fish jq wtype pipes.sh
./install.sh --no-deps
```

### Void Linux

```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh
```

The script uses `xbps-install`. Manual:
```bash
sudo xbps-install -S kitty fastfetch cmatrix cava mpv wireplumber pulseaudio fish jq wtype pipes.sh
./install.sh --no-deps
```

### NixOS

For NixOS, you'll need to set up Hyprland first, then use the manual install:
```bash
git clone https://github.com/YajatGhule/larp.git
cd larp
./install.sh --no-deps
```

All dependencies are usually already available in a Hyprland environment.

## Configuration

After installation, create your config file:

```bash
mkdir -p ~/.config/larp
cp config.example ~/.config/larp/config
```

Then edit `~/.config/larp/config`:

```bash
nano ~/.config/larp/config
```

### Config Options

- **`AUDIO_PATH`** — Full path to an MP3, WAV, FLAC or other audio file.
  - Leave empty (`AUDIO_PATH=""`) to run without music.
  - Example: `AUDIO_PATH="$HOME/Music/synthwave.mp3"`

- **`FONT`** — Font size in the panes (default: `8.0`)
  - Smaller = more content visible. Try `7.0` on 4K, `10.0` on small screens.
  - Override per run: `FONT=10 larp`

- **`SINK`** — PipeWire/Pulse sink to play audio through.
  - Leave empty to use the default output.
  - Find your sinks: `pactl list short sinks`
  - Example: `SINK="alsa_output.pci-0000_00_1f.3.analog-stereo"`

- **`VOLUME`** — Volume percentage (default: `70`)
  - Range: 0–100. Will raise volume smoothly to avoid audio glitches.

### Example Config

```bash
# Song to play
AUDIO_PATH="$HOME/Downloads/synthwave-mix.mp3"

# Font size in panes
FONT="8.5"

# Which speaker/headphones to use (leave empty for default)
SINK="alsa_output.pci-0000_00_1f.3.analog-stereo"

# Volume level
VOLUME=75
```

## Usage

### Basic Usage

```bash
larp
```

Launches the 2×2 grid. Press `Ctrl+C` in any pane to close it. Close the **cava pane** (bottom-right) to stop the music and exit.

### Environment Overrides

Run with different settings without editing the config:

```bash
FONT=10 larp                                    # Larger font
VOLUME=50 larp                                  # Quieter
AUDIO_PATH="" larp                              # No music
FONT=9 VOLUME=80 AUDIO_PATH=/tmp/song.mp3 larp # Multiple overrides
```

### Advanced: larp-ws

`larp-ws` launches larp on workspace 10. It's useful as a macro key or scheduled launcher:

```bash
larp-ws
```

This script (requires `fish`, `jq`, `wtype`):
1. Saves your current workspace
2. Switches to workspace 10
3. Closes any window there
4. Opens a terminal and types `larp`
5. Waits 60 seconds
6. Returns you to the original workspace

### In Your Hyprland Config

Bind it to a key in `~/.config/hypr/hyprland.conf`:

```conf
bind = SUPER, L, exec, larp-ws
```

Or launch it on startup:

```conf
exec = larp-ws
```

## Troubleshooting

### "command not found: larp"

Check that `~/.local/bin` is in your `$PATH`:
```bash
echo $PATH
```

If it's missing, add it to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

Or install to a system directory:
```bash
./install.sh --prefix /usr/local
```

### "hypr-layout: command not found"

The installer couldn't find or build `hypr-layout`. Check:

1. Your system's glibc version:
   ```bash
   ldd --version | head -1
   ```
   If it's older than 2.39, the installer will try to build from source (needs `cargo`).

2. Is Rust installed?
   ```bash
   cargo --version
   ```
   If not: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

3. Manually download the binary:
   ```bash
   mkdir -p ~/.local/bin
   curl -fsSL -o ~/.local/bin/hypr-layout https://github.com/sim590/hypr-layout/releases/download/0.2.0/hypr-layout-0.2.0-x86_64-unknown-linux-gnu
   chmod +x ~/.local/bin/hypr-layout
   ```

### "No music playing"

1. Is `AUDIO_PATH` set in your config?
   ```bash
   cat ~/.config/larp/config | grep AUDIO_PATH
   ```

2. Does the file exist?
   ```bash
   ls -lh "$AUDIO_PATH"  # Make sure you use quotes
   ```

3. Is `mpv` installed?
   ```bash
   mpv --version
   ```

4. Check the sink:
   ```bash
   pactl list short sinks
   ```
   If nothing is listed, your audio isn't set up. Try `wpctl status` or check `journalctl -xe`.

### Pipes/cmatrix lag or glitch

- Try a larger font: `FONT=10 larp`
- Close other CPU-heavy apps
- On slower systems, use a lower refresh rate

### "Hyprland not found"

`larp` only works on [Hyprland](https://hyprland.org/). If you're on another Wayland compositor (GNOME, KDE, Weston), larp won't work. It's written for Hyprland's layout system.

### "permission denied" on install.sh

Make it executable:
```bash
chmod +x install.sh
./install.sh
```

## Building from Source

If you want to modify or develop larp:

```bash
git clone https://github.com/YajatGhule/larp.git
cd larp

# Edit the script
nano larp

# Test it
bash -n larp  # Check syntax
./larp        # Run it
```

`larp` is a single bash script with no external dependencies beyond the programs it calls.

## Uninstalling

```bash
./install.sh --uninstall
```

This removes `larp` and `larp-ws` but keeps your config at `~/.config/larp/config` and dependencies.

To remove everything:
```bash
./install.sh --uninstall
rm -rf ~/.config/larp
```

If you installed to a system prefix:
```bash
./install.sh --prefix /usr/local --uninstall
```

## Getting Help

- **Bug report:** https://github.com/YajatGhule/larp/issues
- **Hyprland help:** https://wiki.hyprland.org/
- **Audio issues:** Check `pactl list short sinks` and `wpctl status`

## License

MIT. See [LICENSE](LICENSE).
