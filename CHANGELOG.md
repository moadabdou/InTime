# Changelog

All notable changes to InTime Widget will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- Command-line arguments for quick color/size changes
- Multiple monitor support
- Animation effects
- Custom time formats
- Keyboard shortcuts for configuration

## [1.0.0] - 2025-12-26

### Added
- Initial release
- Transparent clock overlay for Hyprland
- Dynamic color adaptation based on screen content
- Configurable position presets (center, corners)
- Custom positioning support
- Configurable font size and opacity
- GTK4 Layer Shell integration
- Installation and uninstallation scripts
- Systemd service support
- Comprehensive documentation

### Features
- Real-time clock display (HH:MM:SS)
- Screen color sampling with grim
- Hybrid complementary color algorithm
- Click-through overlay (non-interactive)
- Low resource usage
- Clean configuration file (JSON)

### Dependencies
- Python 3.10+
- GTK4 and GTK4 Layer Shell
- PyGObject
- Pillow (for dynamic colors)
- NumPy (for color calculations)
- grim (for screen sampling)

---

## Version History

- **1.0.0** - Initial public release
