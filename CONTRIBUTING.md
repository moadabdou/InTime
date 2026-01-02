# Contributing to InTime Widget

Thank you for your interest in contributing to InTime Widget!

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on GitHub with:

1. A clear, descriptive title
2. Steps to reproduce the issue
3. Expected behavior
4. Actual behavior
5. Your system information:
   - OS and version
   - Hyprland version
   - Python version
   - GTK4 version

### Suggesting Features

Feature suggestions are welcome! Please open an issue with:

1. Clear description of the feature
2. Use case - why would this be useful?
3. Potential implementation approach (optional)

### Code Contributions

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/intime-widget.git
   cd intime-widget
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Test your changes thoroughly

4. **Test your changes**
   ```bash
   cd src
   ./intime_widget.py
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: brief description of your changes"
   ```

   Commit message prefixes:
   - `Add:` - New feature
   - `Fix:` - Bug fix
   - `Update:` - Enhancement to existing feature
   - `Docs:` - Documentation changes
   - `Refactor:` - Code refactoring

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open a Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Include screenshots for UI changes

## Code Style

- Follow PEP 8 for Python code
- Use meaningful variable names
- Add docstrings for functions and classes
- Keep functions focused and single-purpose
- Comment complex logic

## Testing

Before submitting a PR:

1. Test on a clean Hyprland session
2. Verify transparency works correctly
3. Test with different configurations
4. Check for memory leaks (long-running tests)
5. Ensure dynamic colors work (if enabled)

## Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/intime-widget.git
cd intime-widget

# Make changes to src/
cd src

# Test directly
./intime_widget.py

# Check Python syntax
python3 -m py_compile intime_widget.py
```

## Questions?

Feel free to open an issue for any questions about contributing!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
