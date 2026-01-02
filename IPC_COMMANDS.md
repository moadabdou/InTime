# InTime Widget IPC Commands

The InTime Widget exposes 6 IPC commands via Unix socket at `/tmp/intime_widget.sock`.

## Available Commands

### 1. reload_config
Reload configuration from config.json
```bash
echo "reload_config" | nc -U /tmp/intime_widget.sock
```

### 2. status
Get current widget status and configuration
```bash
echo "status" | nc -U /tmp/intime_widget.sock
```

### 3. forbidden_alarm
Trigger intense visual alarm (used by window rules)
```bash
echo "forbidden_alarm:window_class|window_title|message" | nc -U /tmp/intime_widget.sock
```

### 4. dismiss_alarm
Dismiss the active alarm
```bash
echo "dismiss_alarm" | nc -U /tmp/intime_widget.sock
```

### 5. reset_deadline
Reset from deadline mode back to clock mode
```bash
echo "reset_deadline" | nc -U /tmp/intime_widget.sock
```

### 6. toggle_screen_sampling
Enable/disable real-time screen color sampling
```bash
echo "toggle_screen_sampling" | nc -U /tmp/intime_widget.sock
```

## Multi-Monitor Support

All commands (except `status` and `toggle_screen_sampling`) automatically broadcast to all widget instances when running with `--all-monitors`.

## Response Format

All commands return JSON responses:
- Success: `OK:{"status": "success", ...}`
- Error: `ERROR:error message`
