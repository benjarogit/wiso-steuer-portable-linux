# WISO Steuer (Portable) unter Linux mit Wine

Hilfsskripte und Anleitung, um **Buhl „WISO Steuer“** in der **Portable-Variante** unter **Wine** auf Linux zu nutzen (typisch: **Arch / CachyOS**, **KDE Plasma**, **Wayland**). Dieses Repository enthält **kein** WISO-Programm und steht in **keiner** Verbindung zu Buhl.

- **Deutsch** — diese Datei  
- **English** — [README.md](README.md)

## Was du brauchst

| Voraussetzung | Hinweis |
|----------------|---------|
| Eine **lizenzierte** **Portable**-Installation (Ordner mit `Steuersoftware 20xx`, z. B. `wiso20xx.exe`) | Nur nach Buhl-Lizenz beschaffen und nutzen; nicht weiterverbreiten. |
| **Wine** (64-Bit, Prefix `win64`) | z. B. Wine 9+ / 10+ aus deiner Distribution. |
| **Winetricks** | Für VC++-Laufzeiten, Schriftarten, ggf. D3D-Hilfsdateien. |
| ~1–2 GB Speicher für ein **eigenes Wine-Prefix** | Standard: `~/.local/share/wineprefixes/wiso2026` (änderbar mit `WINEPREFIX`). |

### Wine + Winetricks installieren (Beispiele)

- **Arch / CachyOS / Manjaro**  
  `sudo pacman -S wine winetricks`

- **Debian / Ubuntu**  
  `sudo apt install wine winetricks`

- **Fedora**  
  `sudo dnf install wine winetricks`

Details siehe Doku deiner Distribution.

## Schnellstart

1. **Repository klonen** (oder Release-Archiv laden):  
   [github.com/benjarogit/wiso-steuer-portable-linux](https://github.com/benjarogit/wiso-steuer-portable-linux)

2. **Wine-Prefix anlegen und vorbereiten** (einmal pro Rechner / pro gewähltem Prefix-Pfad):

   ```bash
   cd wiso-steuer-portable-linux
   ./scripts/setup-wine-prefix.sh
   ```

   Dabei passiert u. a.:
   - leeres Prefix unter `~/.local/share/wineprefixes/wiso2026` wird angelegt, falls nötig;
   - Winetricks: **vcrun2022**, **corefonts**, **d3dcompiler_47**, **gdiplus**;
   - Windows-Version: **win10**;
   - Registry: `HKEY_CURRENT_USER\Software\Wine\Drivers\Graphics` = **`x11`** (hilft auf vielen Wayland-Setups).

3. **Launcher ins Portable kopieren** und **Menü-/Desktop-Einträge** erzeugen:

   ```bash
   ./install.sh "/pfad/zu/WISO Steuer 2026 ... Portable"
   ```

4. WISO starten:
   - Anwendungsmenü: **WISO Steuer (Wine)**, oder  
   - Terminal: `"/pfad/.../Portable/wiso-mit-wine.sh"`

## Erwarteter Portable-Ordner (Beispiel)

Jahr und genauer Name können abweichen:

```text
WISO Steuer 20xx … Portable/
  wiso-mit-wine.sh          ← wird von install.sh dorthin kopiert
  Steuersoftware 20xx/
    wiso20xx.exe
    wisoakt.ico
    …
```

Wenn dein Softwareordner anders heißt:

```bash
export WISO_STEUER_SOFTWARE_DIR="Steuersoftware 2027"
```

Wenn die Haupt-EXE **nicht** `wiso2026.exe` heißt:

```bash
export WISO_MAIN_EXE="wiso2027.exe"
```

## Umgebungsvariablen (Launcher)

| Variable | Zweck |
|----------|--------|
| `WINEPREFIX` | Pfad zum Wine-Prefix (Default: `~/.local/share/wineprefixes/wiso2026`) |
| `WISO_KEEP_WAYLAND=1` | **`WAYLAND_DISPLAY` nicht** leeren (Standard ist: leeren für bessere Fenstergeometrie unter Plasma Wayland) |
| `WISO_VIRTUAL_DESKTOP=1920x1000` | **Virtueller Wine-Desktop** in dieser Auflösung (oft besser, wenn oben etwas abgeschnitten wirkt) |
| `WISO_NO_CLEAR_VDESKTOP=1` | Virtuelle-Desktop-Registry-Einträge **nicht** entfernen, wenn du ohne `WISO_VIRTUAL_DESKTOP` startest |
| `WISO_STEUER_SOFTWARE_DIR` | Name des Unterordners unter dem Portable-Root (Default: `Steuersoftware 2026` bzw. erster `Steuersoftware*`-Treffer) |
| `WISO_MAIN_EXE` | EXE-Name, falls kein `wiso*.exe` gefunden wird |

## Fehlersuche

### Oben abgeschnitten (KDE / Wayland)

- Häufig **nur optisch**; **Steuerlogik und Dateien** sind trotzdem in Ordnung, solange alles klickbar ist.
- Bereits eingerichtet: **Graphics = x11** im Prefix, Launcher leert standardmäßig **`WAYLAND_DISPLAY`**.
- **Zweiter Menüeintrag (virt. Desktop)** nutzen oder:  
  `WISO_VIRTUAL_DESKTOP=1920x1000 "/pfad/wiso-mit-wine.sh"`
- **Vergleichstest:** Sitzung **Plasma (X11)** statt Wayland (abmelden → Sitzung wählen).
- **winecfg** → **Grafik** → Option **„Erlaube dem Fenstermanager…“** an/aus testen.

### Installation / Updater

Manche offiziellen **Setup-/Update-Programme** scheitern unter Wine. Die **Portable-Struktur** nutzt in der Regel **kein** vollständiges Windows-Setup im gleichen Sinne. **Updates** klärst du mit Buhl bzw. im Kundenkonto; ggf. anderer PC oder Windows-VM.

### Hilfe / Browser / .NET-Teil

Falls Zusatzprogramme (z. B. .NET) fehlen, kann man im **gleichen Prefix** z. B. per Winetricks **`dotnet472`** nachrüsten (groß, experimentell).

## Deinstallieren (nur Helfer / Menüeinträge)

- Optional `wiso-mit-wine.sh` im Portable-Ordner löschen.
- Desktop-Dateien löschen:  
  `~/.local/share/applications/wiso-steuer-wine.desktop`  
  `~/.local/share/applications/wiso-steuer-wine-vdesktop.desktop`
- Optional Symlink: `~/.local/share/icons/wiso-steuer-wine.ico`
- Optional ganzes Wine-Prefix **nur** wenn du es nicht mehr brauchst (WISO-Dateien im Portable-Ordner bleiben unberührt):  
  `rm -rf ~/.local/share/wineprefixes/wiso2026`

## Rechtliches

Die Inhalte **dieses** Repos (Skripte + Doku) stehen unter der [MIT License](LICENSE). **WISO Steuer** und Marken gehören den Rechteinhabern. Du musst **eigenverantwortlich** die Bedingungen deiner WISO- und Drittlizenzen einhalten.

## Ins leere GitHub-Repo pushen

```bash
cd wiso-steuer-portable-linux
git init
git add .
git commit -m "Initial import: documentation and helper scripts"
git branch -M main
git remote add origin https://github.com/benjarogit/wiso-steuer-portable-linux.git
git push -u origin main
```

(Bei Bedarf `git@github.com:...` statt HTTPS.)
