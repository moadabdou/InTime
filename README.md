# InTime Widget

A production-ready, transparent time display overlay for Hyprland with multiple display modes and stunning visual effects.

## Features

### Display Modes
- **Clock Mode**: Standard digital clock (HH:MM:SS)
- **Countdown Mode**: Timer with custom duration (e.g., 30m, 1h30m)
- **Midnight Mode**: Countdown to end of day (23:59:59)
- **Deadline Mode**: Horror-style countdown with progressive urgency effects

### Visual Styles
- **Normal**: Clean, bold monospace text
- **Lightbulb**: 3 Body Problem-inspired particle glow effect
- **Bordered**: Text with dark outline for better visibility

### Advanced Features
- **Forbidden Alarm**: Intense visual alarm with waves, shake, and pulsing effects
- **Multi-Monitor Support**: Display on one or all monitors simultaneously
- **Screen Color Sampling**: Real-time adaptive color based on screen content
- **Click-Through Overlay**: Never interferes with your workflow
- **IPC Control**: 6 commands for dynamic control via Unix socket

## Installation

### Dependencies
```bash
# GTK4 and Layer Shell
sudo pacman -S gtk4 gtk4-layer-shell

# Python dependencies
sudo pacman -S python python-gobject python-cairo
```

### Setup
```bash
cd /home/mathis/wtdo/intime_widget
# The widget is ready to run from src/intime_widget.py
```

## Usage

### Basic Examples
```bash
# Show current time
./src/intime_widget.py

# 30-minute countdown
./src/intime_widget.py --mode countdown --duration 30m

# Countdown to midnight with sci-fi glow
./src/intime_widget.py --mode midnight --style lightbulb

# Horror-style deadline (1 hour)
./src/intime_widget.py --mode deadline --duration 1h

# Display on all monitors
./src/intime_widget.py --all-monitors

# Custom color and opacity
./src/intime_widget.py --color "#FF0000" --opacity 0.7
```

### Command-Line Options
```
--mode {clock,countdown,midnight,deadline}
    Display mode (default: clock)

--duration DURATION
    Duration for countdown/deadline modes (e.g., 30m, 1h30m, 45s)

--color COLOR
    Text color in hex format (e.g., #FF0000)

--font-size SIZE
    Font size in pixels (default: from config.json)

--opacity OPACITY
    Text opacity 0.0-1.0 (default: from config.json)

--style {normal,lightbulb}
    Visual style (default: normal)

--monitor INDEX
    Monitor index (0=primary, 1=secondary, etc.)

--all-monitors
    Display on all connected monitors
```

## Configuration

Edit `config.json` to customize default settings:

```json
{
  "color": "#FFFFFF",
  "font_size": 78,
  "style": "normal",
  "opacity": 0.5,
  "position_mode": "preset",
  "position_preset": "center",
  "screen_sampling": {
    "enabled": false
  }
}
```

### Position Presets
- `center`: Full-screen centered
- `top-left`: Upper left corner
- `top-right`: Upper right corner
- `bottom-left`: Lower left corner
- `bottom-right`: Lower right corner

## IPC Commands

Control the widget via Unix socket at `/tmp/intime_widget.sock`:

```bash
# Reload configuration
echo "reload_config" | nc -U /tmp/intime_widget.sock

# Get status
echo "status" | nc -U /tmp/intime_widget.sock

# Trigger alarm
echo "forbidden_alarm:class|title|Custom Message" | nc -U /tmp/intime_widget.sock

# Dismiss alarm
echo "dismiss_alarm" | nc -U /tmp/intime_widget.sock

# Reset from deadline mode
echo "reset_deadline" | nc -U /tmp/intime_widget.sock

# Toggle screen color sampling
echo "toggle_screen_sampling" | nc -U /tmp/intime_widget.sock
```

See `IPC_COMMANDS.md` for complete documentation.

## Architecture

### File Structure
```
intime_widget/
├── src/
│   ├── intime_widget.py          # Main widget (1292 lines)
│   └── screen_color_monitor.py   # Screen sampling module
├── config.json                    # Configuration file
├── README.md                      # This file
└── IPC_COMMANDS.md               # IPC reference
```

### Key Components

**IPCServer Class** (Lines 38-131)
- Unix socket server for remote control
- 6 registered commands
- Shared across all widget instances

**InTimeWidget Class** (Lines 227-1192)
- Main widget implementation
- Complete rendering pipeline
- Animation system (3 separate timers)
- Multi-monitor support
- Screen color sampling integration

**InTimeApplication Class** (Lines 1194-1251)
- GTK Application wrapper
- Multi-monitor widget creation
- Application lifecycle management

### Rendering Pipeline

1. **on_draw()** (Lines 497-609)
   - Mode-based time calculation
   - Color parsing and flash effects
   - Style routing to specialized renderers

2. **Specialized Renderers**
   - `_draw_lightbulb_text()`: Particle-based glow (15 layers + 4 core)
   - `_draw_bordered_text()`: Simple outline effect
   - `_draw_forbidden_alarm()`: 12-layer glow + waves + shake
   - `_draw_deadline_countdown()`: Progressive urgency effects

3. **Animation System**
   - 1Hz: Main time updates (`update_time`)
   - 20Hz: Lightbulb animation (`update_animation`)
   - 3Hz: Deadline animation (`update_animation`)
   - 10Hz: Alarm animation (`update_alarm_animation`)

## Performance Notes

- Optimized layer counts for all visual effects
- Deadline mode uses 3fps animation (low CPU)
- Lightbulb mode uses 20fps (smooth but efficient)
- Alarm effects use 10fps (balanced intensity)
- Screen sampling is disabled by default

## What Was Removed

This is a clean time-display widget. All task-tracking features have been removed:
- Task class and TaskManager
- Database integration (db_config)
- Window tracker
- Idle tracker
- Workspace monitor
- Task input/list UI
- Force mode
- Task-related IPC commands

## Development

### Testing
```bash
# Syntax check
python3 -m py_compile src/intime_widget.py

# Run with debug output
./src/intime_widget.py --mode clock 2>&1 | tee debug.log
```

### Dependencies Required
- Python 3.x
- GTK 4.0
- GTK4LayerShell 1.0
- Cairo
- Pango
- screen_color_monitor.py (included)

## License

Part of the wtdo project.

## Credits

Created by transferring and refactoring code from clock_widget.py, removing all task-tracking features while preserving the complete time display and animation system.
