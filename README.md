# Headset Control Plasma 6 Widget

This is a **KDE Plasma 6** port of the original [Headset Control Plasmoid](https://github.com/lazy-stripes/plasmoid-headsetcontrol) by lazy-stripes.

It displays the battery status of your wireless headset and allows you to control features like sidetone, lights, and voice prompts (if supported).

## Requirements

*   **KDE Plasma 6**
*   **HeadsetControl**: You must have the [HeadsetControl](https://github.com/Sapd/HeadsetControl) command-line tool installed and working.
    *   Test it by running `headsetcontrol -b` in your terminal.

## Installation

### From Source

1.  Clone this repository:
    ```bash
    git clone https://github.com/YOUR_USERNAME/plasmoid-headsetcontrol-plasma6.git
    cd plasmoid-headsetcontrol-plasma6
    ```

2.  Install using `kpackagetool6`:
    ```bash
    kpackagetool6 --type Plasma/Applet --install package
    ```
    (If updating, use `--upgrade` instead of `--install`)

3.  Add the widget to your panel or desktop:
    *   Right-click desktop/panel -> **Add Widgets...**
    *   Search for **"Headset Control"**.

## Configuration

*   **Binary Path**: By default, it looks for `headsetcontrol` in `/usr/bin/headsetcontrol`. If you installed it manually to `/usr/local/bin` or elsewhere, open the widget settings and update the path.
*   **Polling Rate**: Adjustable in settings (default 5000ms).

## Changes from Original

*   Ported to Plasma 6 API (`org.kde.plasma.plasmoid`, `Plasma5Support`, `Kirigami`).
*   Updated QML imports to Qt 6 standards (`QtQuick 2.15`, `Controls 2.15`).
*   Replaced deprecated components (`PlasmaCore.DataSource`, `IconItem`, etc.).
*   Fixed settings dialog (removed deprecated file dialog shortcuts).
*   Added Plasma 6 metadata (`X-Plasma-API-Minimum-Version`).

## License

GPL-3.0
