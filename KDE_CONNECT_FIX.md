# KDE Connect Remote Control Fix on Hyprland (Wayland)

## 1. Problem Description
When using KDE Connect's **Remote Input** (using your phone as a trackpad/mouse and keyboard for your laptop), the cursor would work for 1–2 seconds and then freeze permanently. Subsequent attempts to move the pointer produced continuous errors in `journalctl`:
```text
kdeconnectd: Failed to create keymap
kdeconnectd: xkbcommon: ERROR: [XKB-769] (input string):279:14: syntax error, unexpected end of file
kdeconnectd: QSocketNotifier: Invalid socket 45 and type 'Read', disabling...
kdeconnectd: failed to send message: Bad file descriptor
kdeconnectd: ERROR | Bug: ei_device_pointer_motion: device is not emulating
```

---

## 2. Root Cause Analysis

### A. XDG Desktop Portal Routing Under Hyprland
- When running Hyprland (`XDG_CURRENT_DESKTOP=Hyprland`), `xdg-desktop-portal` gives strict priority to `~/.config/xdg-desktop-portal/hyprland-portals.conf` and completely ignores generic `portals.conf`.
- `hyprland-portals.conf` previously only specified `default=hyprland;gtk`.
- Neither `xdg-desktop-portal-hyprland` nor `xdg-desktop-portal-gtk` implements `org.freedesktop.impl.portal.RemoteDesktop`. This caused the portal lookup to fail or fall back unexpectedly.

### B. The `ConnectToEIS` / `libei` Socket Drop Bug
- `hypr-kdeconnect-portal` was advertising RemoteDesktop version `2` (`version = 2u`).
- RemoteDesktop v2 prompts KDE Connect to use `ConnectToEIS` (the Emulated Input Server via `libei`).
- In KDE Connect on Wayland, this EIS bridge encounters a serialization bug during XKB keymap transmission (`unexpected end of file`, buffer truncation), causing the EIS UNIX socket (e.g., fd 45) to close (`Bad file descriptor`).
- Once the socket drops, KDE Connect's internal pointer device desynchronizes from the session, throwing `ei_device_pointer_motion: device is not emulating` indefinitely.

---

## 3. The Solution Implemented

### Step 1: Fix Portal Routing Configurations
Added explicit routing for `RemoteDesktop` in both configuration files:

**`~/.config/xdg-desktop-portal/hyprland-portals.conf`**:
```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.RemoteDesktop=hypr-kdeconnect
```

**`~/.config/xdg-desktop-portal/portals.conf`**:
```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.RemoteDesktop=hypr-kdeconnect
```

### Step 2: Patch `hypr-kdeconnect-portal` to use RemoteDesktop v1
- In `src/portal_backend.cpp`, modified the advertised `RemoteDesktop` interface version from `2u` to `1u`:
  ```cpp
  // RemoteDesktop interface property:
  if (property == QStringLiteral("version"))
      return QVariant::fromValue(1u);
  ```
- **Why this works:** When version is `1`, KDE Connect automatically bypasses the buggy `ConnectToEIS` path and falls back to standard `NotifyPointerMotion`, `NotifyPointerButton`, and `NotifyPointerAxisDiscrete` D-Bus calls.
- `hypr-kdeconnect-portal` translates these calls directly into Hyprland compositor events using `zwlr_virtual_pointer_v1` and `zwp_virtual_keyboard_v1`. This completely circumvents the socket crashes and keymap truncation errors.

### Step 3: Build and Deploy Patched Binary
- Compiled `hypr-kdeconnect-portal` with Ninja/CMake and passed all 4 test suites (`key-resolver-test`, `security-policy-test`, `portal-metadata-test`, `hardening-readelf-test`).
- Replaced `/usr/bin/hypr-kdeconnect-portal` with the newly built binary.

### Step 4: Restarted Services
```bash
systemctl --user daemon-reload
systemctl --user restart xdg-desktop-portal
systemctl --user restart hypr-kdeconnect-portal.service
killall -9 kdeconnectd kdeconnect-app
nohup /usr/bin/kdeconnectd --replace >/dev/null 2>&1 &
```

---

## 4. Verification
- Confirmed `org.freedesktop.impl.portal.desktop.hypr_kdeconnect` is active and exporting RemoteDesktop v1.
- Verified `iQOO Z5` is paired, reachable on LAN (`10.46.147.5`), and that pointer injection does not drop sockets.
