# WISO Steuer (Portable) on Linux with Wine

Helper scripts and documentation for running **Buhl “WISO Steuer” portable** builds under **Wine** on Linux (tested mindset: **Arch / CachyOS**, **KDE Plasma**, **Wayland**). This repository does **not** contain WISO itself and is not affiliated with Buhl.

- **English** — this file  
- **Deutsch** — [README.de.md](README.de.md)

## What you need

| Requirement | Notes |
|---------------|--------|
| A **licensed** copy of **WISO Steuer** in the **portable** layout (folder with `Steuersoftware 20xx` and e.g. `wiso20xx.exe`) | Obtain and use according to Buhl’s license; do not redistribute. |
| **Wine** (64-bit, `win64` prefix) | e.g. `wine` 9+ or 10+ from your distro. |
| **Winetricks** | For VC++ runtimes, fonts, D3D helper, etc. |
| ~1–2 GB disk for a dedicated **Wine prefix** (Windows profile) | Default: `~/.local/share/wineprefixes/wiso2026` (change with `WINEPREFIX`). |

### Install Wine + Winetricks (examples)

- **Arch / CachyOS / Manjaro**  
  `sudo pacman -S wine winetricks`

- **Debian / Ubuntu**  
  `sudo apt install wine winetricks`

- **Fedora**  
  `sudo dnf install wine winetricks`

Use your distribution’s documentation if packages differ.

## Quick start

1. **Clone** this repository (or download a release archive).

2. **Create and prepare the Wine prefix** (once per machine / once you are happy with the prefix path):

   ```bash
   cd wiso-steuer-portable-linux
   ./scripts/setup-wine-prefix.sh
   ```

   This will:
   - create `~/.local/share/wineprefixes/wiso2026` if missing;
   - install **vcrun2022**, **corefonts**, **d3dcompiler_47**, **gdiplus** via winetricks;
   - set Windows version to **win10**;
   - set `HKEY_CURRENT_USER\Software\Wine\Drivers\Graphics` to **`x11`** (useful on many Wayland setups).

3. **Copy the launcher** into your **portable** directory and install **menu / desktop entries**:

   ```bash
   ./install.sh "/path/to/WISO Steuer 2026 ... Portable"
   ```

4. Start WISO:
   - from the app menu (**WISO Steuer (Wine)**), or  
   - from a terminal:  
     `"/path/to/... Portable/wiso-mit-wine.sh"`

## Default layout (portable tree)

The launcher expects this structure (year may differ):

```text
WISO Steuer 20xx … Portable/
  wiso-mit-wine.sh          ← installed by install.sh
  Steuersoftware 20xx/
    wiso20xx.exe
    wisoakt.ico
    …
```

If your software folder has another name, set:

```bash
export WISO_STEUER_SOFTWARE_DIR="Steuersoftware 2027"
```

If the main EXE is not `wiso2026.exe`, set e.g.:

```bash
export WISO_MAIN_EXE="wiso2027.exe"
```

## Environment variables (launcher)

| Variable | Purpose |
|----------|---------|
| `WINEPREFIX` | Wine prefix path (default: `~/.local/share/wineprefixes/wiso2026`) |
| `WISO_KEEP_WAYLAND=1` | Do **not** unset `WAYLAND_DISPLAY` (default is to unset for better geometry on Plasma Wayland) |
| `WISO_VIRTUAL_DESKTOP=1920x1000` | Run inside Wine’s **virtual desktop** of that size (often helps if the top of the window looks clipped) |
| `WISO_NO_CLEAR_VDESKTOP=1` | If set, do not clear virtual-desktop registry keys when not using `WISO_VIRTUAL_DESKTOP` |
| `WISO_STEUER_SOFTWARE_DIR` | Subfolder name under the portable root (default: `Steuersoftware 2026` or first `Steuersoftware*`) |
| `WISO_MAIN_EXE` | Main EXE name if not auto-detected |

## Troubleshooting

### Top of the window looks “cut off” (KDE / Wayland)

- Often **cosmetic**; tax logic and data are still fine if you can use all controls.
- Already covered by: **`Graphics=x11`** in the prefix and the launcher **unsetting `WAYLAND_DISPLAY`**.
- **Try** the second menu entry **(virtual desktop)** or run:  
  `WISO_VIRTUAL_DESKTOP=1920x1000 "/path/to/wiso-mit-wine.sh"`
- **Try** an **X11** Plasma session instead of Wayland (logout → “Plasma (X11)”) to compare.
- In `winecfg` → **Graphics**: toggle **“Allow the window manager to control the windows”** and test.

### Updates / official installer

Some Buhl **installers** or **updaters** fail under Wine (e.g. `%TEMP%` / ACL checks). The **portable** tree avoids the main installer. Update strategies are between you and Buhl (e.g. customer portal; another machine; Windows VM).

### Help, browser, or .NET sub-features

The portable tree may include **.NET**-based helpers. If something fails, you may add to the same prefix, e.g. with winetricks: `dotnet472` (large download). YMMV.

### Menu / desktop icon shows a blank “document”

KDE and other desktops often **do not render `.ico`** paths in `.desktop` files reliably (especially **symlinks** to an ICO on another disk). `install.sh` therefore converts `wisoakt.ico` to **PNG** files under `~/.local/share/icons/hicolor/*/apps/wiso-steuer-wine.png` and sets `Icon=wiso-steuer-wine`. Re-run `./install.sh "<portable-path>"` after moving the portable folder. If the icon still does not refresh, run `kbuildsycoca6 --noincremental` (Plasma 6) or log out and back in.

## Uninstall (helper / menu entries only)

- Remove launcher from the portable folder: `wiso-mit-wine.sh` (optional).
- Remove desktop files:  
  `~/.local/share/applications/wiso-steuer-wine.desktop`  
  `~/.local/share/applications/wiso-steuer-wine-vdesktop.desktop`
- Remove installed icons: `rm -rf ~/.local/share/icons/hicolor/*/apps/wiso-steuer-wine.png` and any `~/.local/share/icons/wiso-steuer-wine.ico` symlink left from older installs
- Optional: remove the Wine prefix directory (backs up **nothing** from WISO; only Wine’s fake Windows):  
  `rm -rf ~/.local/share/wineprefixes/wiso2026`

## Legal

Scripts and documentation in this repository are under the [MIT License](LICENSE). **WISO Steuer** and related marks belong to their owners. You must **comply** with the license and terms of any third-party software you use.

## Repository

Project home: [github.com/benjarogit/wiso-steuer-portable-linux](https://github.com/benjarogit/wiso-steuer-portable-linux)

## Publishing to GitHub (empty repo)

If the remote is still empty:

```bash
cd wiso-steuer-portable-linux
git init
git add .
git commit -m "Initial import: documentation and helper scripts"
git branch -M main
git remote add origin https://github.com/benjarogit/wiso-steuer-portable-linux.git
git push -u origin main
```

(Use SSH URL instead if you prefer.)
