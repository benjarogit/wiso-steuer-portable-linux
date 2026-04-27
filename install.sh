#!/usr/bin/env sh
# Copy launcher into your portable folder and install KDE/GNOME-style .desktop entries.
#
# Usage:
#   ./install.sh "/absolute/or/relative/path/to/WISO Steuer 20xx Portable"
#
# Optional environment:
#   VDESKTOP_SIZE=1920x1000   # resolution for optional "virtual desktop" menu entry
#   SKIP_DESKTOP=1            # only copy wiso-mit-wine.sh, no menu icons

set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:?Usage: $0 </path/to/WISO Steuer ... Portable>}"

if [ ! -d "$TARGET" ]; then
	echo "Not a directory: $TARGET" >&2
	exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if [ ! -d "$TARGET/Steuersoftware 2026" ] && ! ls -d "$TARGET"/Steuersoftware* >/dev/null 2>&1; then
	echo "Warning: no 'Steuersoftware*' folder found under $TARGET — script still copies launcher (auto-detect at runtime)." >&2
fi

cp -f "$REPO_ROOT/scripts/wiso-mit-wine.sh" "$TARGET/wiso-mit-wine.sh"
chmod +x "$TARGET/wiso-mit-wine.sh"
echo "Installed: $TARGET/wiso-mit-wine.sh"

VDESKTOP_SIZE="${VDESKTOP_SIZE:-1920x1000}"
ICON_SRC="$TARGET/Steuersoftware 2026/wisoakt.ico"
if [ ! -f "$ICON_SRC" ]; then
	_icon="$(find "$TARGET" -maxdepth 3 -name 'wisoakt.ico' -type f 2>/dev/null | head -1 || true)"
	if [ -n "$_icon" ]; then
		ICON_SRC="$_icon"
	fi
fi

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
mkdir -p "$APP_DIR" "$ICON_DIR"

# KDE/GNOME often ignore or mishandle .ico paths in .desktop files (especially symlinks).
# Install PNGs under ~/.local/share/icons/hicolor/.../apps/ and use Icon=wiso-steuer-wine.
ICON_LINE='Icon=wine'
ICON_THEME_NAME="wiso-steuer-wine"
if [ -f "$ICON_SRC" ]; then
	HICOLOR="$ICON_DIR/hicolor"
	if command -v magick >/dev/null 2>&1; then
		for _s in 48 64 128 256; do
			mkdir -p "$HICOLOR/${_s}x${_s}/apps"
			magick "${ICON_SRC}[0]" -resize "${_s}x${_s}" "$HICOLOR/${_s}x${_s}/apps/${ICON_THEME_NAME}.png" 2>/dev/null || true
		done
		if [ -f "$HICOLOR/48x48/apps/${ICON_THEME_NAME}.png" ]; then
			ICON_LINE="Icon=${ICON_THEME_NAME}"
			if command -v gtk-update-icon-cache >/dev/null 2>&1; then
				gtk-update-icon-cache -f -t "$HICOLOR" 2>/dev/null || true
			fi
			if command -v kbuildsycoca6 >/dev/null 2>&1; then
				kbuildsycoca6 --noincremental 2>/dev/null || true
			elif command -v kbuildsycoca5 >/dev/null 2>&1; then
				kbuildsycoca5 --noincremental 2>/dev/null || true
			fi
			echo "Installed PNG icons: $HICOLOR/*/apps/${ICON_THEME_NAME}.png (Icon=${ICON_THEME_NAME})"
		else
			cp -f "$ICON_SRC" "$ICON_DIR/${ICON_THEME_NAME}.ico"
			ICON_LINE="Icon=$ICON_DIR/${ICON_THEME_NAME}.ico"
			echo "ImageMagick failed; copied ICO to: $ICON_DIR/${ICON_THEME_NAME}.ico"
		fi
	else
		cp -f "$ICON_SRC" "$ICON_DIR/${ICON_THEME_NAME}.ico"
		ICON_LINE="Icon=$ICON_DIR/${ICON_THEME_NAME}.ico"
		echo "No 'magick' found; copied ICO to: $ICON_DIR/${ICON_THEME_NAME}.ico (install imagemagick for better KDE icons)"
	fi
else
	echo "Note: wisoakt.ico not found; .desktop files will use generic wine icon."
fi

_escape_for_desktop() {
	printf '%s' "$1" | sed 's/[\\"]/\\&/g'
}

LAUNCHER="$TARGET/wiso-mit-wine.sh"
LAUNCH_ESC="$(_escape_for_desktop "$LAUNCHER")"

if [ -z "${SKIP_DESKTOP:-}" ]; then
	cat >"$APP_DIR/wiso-steuer-wine.desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=WISO Steuer (Wine)
Comment=Portable WISO via Wine (see wiso-steuer-portable-linux)
Exec="$LAUNCH_ESC"
Categories=Office;Finance;
Terminal=false
StartupNotify=true
Keywords=tax;steuer;wiso;buhl;
${ICON_LINE}
EOF

	cat >"$APP_DIR/wiso-steuer-wine-vdesktop.desktop" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=WISO Steuer (Wine, virtual desktop)
Comment=Same launcher with Wine virtual desktop (${VDESKTOP_SIZE})
Exec=env WISO_VIRTUAL_DESKTOP=${VDESKTOP_SIZE} "$LAUNCH_ESC"
Categories=Office;Finance;
Terminal=false
StartupNotify=true
Keywords=tax;steuer;wiso;buhl;
${ICON_LINE}
EOF

	if command -v update-desktop-database >/dev/null 2>&1; then
		update-desktop-database "$APP_DIR" 2>/dev/null || true
	fi
	echo "Desktop entries: $APP_DIR/wiso-steuer-wine.desktop"
	echo "                 $APP_DIR/wiso-steuer-wine-vdesktop.desktop"
fi

echo
echo "Optional: run setup once: $REPO_ROOT/scripts/setup-wine-prefix.sh"

exit 0
