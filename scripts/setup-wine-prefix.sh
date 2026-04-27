#!/usr/bin/env sh
# One-time: create 64-bit Wine prefix for WISO portable + winetricks runtimes
# and prefer the X11 graphics driver in Wine (helps on many Wayland setups).
#
# Usage: ./setup-wine-prefix.sh
# Optional: WINEPREFIX=/path/to/custom ./setup-wine-prefix.sh

set -e

WINEPREFIX="${WINEPREFIX:-$HOME/.local/share/wineprefixes/wiso2026}"
WINEARCH=win64
export WINEPREFIX WINEARCH

if ! command -v wine >/dev/null 2>&1; then
	echo "Error: 'wine' not found. Install Wine for your distribution first (see README)." >&2
	exit 1
fi
if ! command -v winetricks >/dev/null 2>&1; then
	echo "Error: 'winetricks' not found. Install winetricks first (see README)." >&2
	exit 1
fi

echo "Using WINEPREFIX=$WINEPREFIX"
mkdir -p "$(dirname "$WINEPREFIX")"
if [ ! -f "$WINEPREFIX/system.reg" ]; then
	wineboot -i
else
	wine wineboot -u
fi

echo "Installing runtimes (may take a few minutes)..."
winetricks -q vcrun2022 corefonts d3dcompiler_47 gdiplus
winetricks -q settings win10

echo "Preferring the Wine X11 (Xwayland) graphics driver in this prefix..."
wine reg add "HKCU\\Software\\Wine\\Drivers" /v Graphics /t REG_SZ /d x11 /f

echo "Done. You can launch WISO with ./wiso-mit-wine.sh from the portable root."
echo "Optional: install menu/desktop entries with: ./install.sh <path-to-portable-folder>"
