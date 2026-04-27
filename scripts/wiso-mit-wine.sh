#!/usr/bin/env sh
# Launch the portable "WISO Steuer" (year) build via Wine.
# Place this file in the *root* of the portable tree (next to the folder
# "Steuersoftware 2026" or the matching year), then run it.
#
# If the top of the window looks clipped (KDE Plasma + Wayland):
#   1) Use setup-wine-prefix.sh so HKCU\Software\Wine\Drivers\Graphics = x11
#   2) By default this script unsets WAYLAND_DISPLAY (Xwayland path).
#      Set WISO_KEEP_WAYLAND=1 to skip that.
#   3) Fallback: WISO_VIRTUAL_DESKTOP=1920x1000
#
# Disable virtual Wine desktop again: winecfg → Graphics, or
#   wine reg delete "HKCU\Software\Wine\Explorer" /v Desktop /f
#   wine reg delete "HKCU\Software\Wine\Explorer\Desktops" /v Default /f

export WINEPREFIX="${WINEPREFIX:-$HOME/.local/share/wineprefixes/wiso2026}"
export WINEARCH=win64

# Plasma/Wayland: avoid wrong client / decoration geometry for many apps.
if [ -z "$WISO_KEEP_WAYLAND" ]; then
	DISPLAY="${DISPLAY:-:0}"
	export DISPLAY
	unset WAYLAND_DISPLAY
fi

# Optional: Wine virtual desktop (window-in-window; often helps layout glitches).
if [ -n "$WISO_VIRTUAL_DESKTOP" ]; then
	wine reg add "HKCU\\Software\\Wine\\Explorer" /v Desktop /d Default /f >/dev/null 2>&1
	wine reg add "HKCU\\Software\\Wine\\Explorer\\Desktops" /v Default /d "$WISO_VIRTUAL_DESKTOP" /f >/dev/null 2>&1
elif [ -z "$WISO_NO_CLEAR_VDESKTOP" ]; then
	wine reg delete "HKCU\\Software\\Wine\\Explorer" /v Desktop /f >/dev/null 2>&1
	wine reg delete "HKCU\\Software\\Wine\\Explorer\\Desktops" /v Default /f >/dev/null 2>&1
fi

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Folder shipped with the portable build (Buhl naming may include the year).
SOFTWARE_DIR="${WISO_STEUER_SOFTWARE_DIR:-Steuersoftware 2026}"
if [ ! -d "$ROOT_DIR/$SOFTWARE_DIR" ]; then
	# Heuristic: first directory matching "Steuersoftware*"
	_alt="$(ls -d "$ROOT_DIR"/Steuersoftware* 2>/dev/null | head -1 || true)"
	if [ -n "$_alt" ] && [ -d "$_alt" ]; then
		SOFTWARE_DIR="${_alt##*/}"
	else
		echo "Cannot find a 'Steuersoftware*' directory next to this script. Set WISO_STEUER_SOFTWARE_DIR." >&2
		exit 1
	fi
fi
cd "$ROOT_DIR/$SOFTWARE_DIR" || exit 1

MAIN_EXE="${WISO_MAIN_EXE:-wiso2026.exe}"
if [ ! -f "$MAIN_EXE" ]; then
	_cand=$(find . -maxdepth 1 -name 'wiso*.exe' -type f 2>/dev/null | head -1 || true)
	if [ -n "$_cand" ]; then
		MAIN_EXE="${_cand#./}"
	else
		echo "Main executable not found. Set WISO_MAIN_EXE=... to your wiso20xx.exe" >&2
		exit 1
	fi
fi

exec wine "$MAIN_EXE" "$@"
