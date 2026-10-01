# Quickshell Configuration: Niri Status Bar

This directory contains a custom status bar configuration for the [Niri](https://github.com/YaLTeR/niri) compositor, built using [Quickshell](https://github.com/outfoxxed/quickshell).

## Project Overview

- **Purpose:** A lightweight, vertical status bar positioned on the left side of the screen.
- **Key Features:**
  - **Niri Workspace Indicator:** Real-time updates via Niri's `event-stream` IPC. Workspaces are sorted by index and support click-to-focus.
  - **Vertical Clock/Date:** Time and date displayed in a vertical stack for readability in narrow bars.
  - **Aesthetics:** Uses a dark theme (Catppuccin-inspired) with smooth color transitions for active states.
- **Technologies:** QML, Quickshell (Wayland, Io modules), Niri IPC (`niri msg`).

## Key Files

- `shell.qml`: The main configuration file defining the bar's layout, logic, and styling.
- `.qmlls.ini`: Configuration for the QML Language Server (if applicable).

## Building and Running

To run the status bar, ensure `quickshell` and `niri` are installed, then execute:

```bash
quickshell --config /projects/dotfiles/config/quickshell
```

Alternatively, you can run the QML file directly:

```bash
quickshell --path /projects/dotfiles/config/quickshell/shell.qml
```

## Development Conventions

- **IPC Handling:** Uses Quickshell's `Process` and `SplitParser` to interact with `niri msg`.
- **Layout:** Primarily uses `ColumnLayout` and `RowLayout` for positioning.
- **Responsiveness:** The bar uses `WlrLayershell.exclusiveZone` to reserve screen space in Niri.
- **Sorting:** Workspace data from Niri is manually sorted by `idx` before being assigned to the UI model.
- **Interaction:** Dynamic actions (like switching workspaces) are handled by reconfiguring and restarting a dedicated `Process` object (`niriClickProc`).

## TODO / Future Improvements
- [ ] Add system tray support (if Quickshell modules allow).
- [ ] Integrate battery and network status indicators.
- [ ] Support for multiple monitors (currently anchors to the default screen).
