# InTime Widget - Quick Start Guide

## What is InTime Widget?

InTime is a beautiful, transparent clock widget designed specifically for Hyprland. It displays the current time as an always-on-top overlay with dynamic color adaptation that automatically adjusts to your screen content for optimal visibility.

## Quick Installation

```bash
cd intime_widget
./scripts/install.sh
```

The installer will:
- Copy files to `~/.local/bin/` and `~/.config/intime/`
- Check for required dependencies
- Optionally create a systemd service for autostart

## Testing the Widget

After installation, simply run:

```bash
intime-widget
```

You should see a transparent clock overlay on your screen!

## First Configuration

Edit the config file:

```bash
nano ~/.config/intime/config.json
```

Try changing:
- `"color"`: Color of the clock (e.g., `"#FF0000"` for red)
- `"font_size"`: Size of the clock (default: 120)
- `"position_preset"`: Where to show the clock (`"center"`, `"top-left"`, etc.)
- `"opacity"`: Transparency (0.0 = invisible, 1.0 = solid)

After saving changes, restart the widget:

```bash
pkill -f intime-widget && intime-widget &
```

## Enable Dynamic Colors

Want the clock to auto-adjust its color based on screen content?

Edit `~/.config/intime/config.json`:

```json
{
  "dynamic_colors": {
    "enabled": true,
    "update_interval": 0.5,
    "throttle_threshold": 15
  }
}
```

This makes the clock always visible by choosing colors that contrast with your screen!

## Autostart on Login

### Method 1: Hyprland Config (Recommended)

Add to `~/.config/hypr/hyprland.conf`:

```conf
exec-once = intime-widget
```

### Method 2: Systemd Service

```bash
systemctl --user enable intime-widget.service
systemctl --user start intime-widget.service
```

## Troubleshooting

**Widget not visible?**
- Check that Hyprland is running
- Verify GTK4 Layer Shell is installed: `ldconfig -p | grep gtk4-layer-shell`

**Colors not changing?**
- Ensure `grim` is installed: `which grim`
- Enable dynamic colors in config (see above)

**High CPU usage?**
- Increase `update_interval` to 1.0 or higher
- Disable dynamic colors if not needed

## Uninstalling

```bash
cd intime_widget
./scripts/uninstall.sh
```

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- See [CHANGELOG.md](CHANGELOG.md) for version history

## Need Help?

- Open an issue on GitHub
- Check existing issues for solutions
- Read the full README for advanced configuration

Enjoy your new clock widget!
