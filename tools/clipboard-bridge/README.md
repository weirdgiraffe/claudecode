# Clipboard Bridge

A simple TCP-based clipboard bridge that allows Docker containers running on macOS to access the host's clipboard.

## Overview

This service runs on the macOS host and exposes the system clipboard via a simple HTTP API over TCP. Containers can then communicate with the host's clipboard through `host.docker.internal:9999`.

## Building

```bash
go build -o clipboard-bridge main.go
```

## Running

```bash
./clipboard-bridge
```

The bridge will listen on `0.0.0.0:9999` by default.

### Custom Port

To use a different port, set the environment variable:

```bash
CLIPBOARD_BRIDGE_PORT=8888 ./clipboard-bridge
```

## API

### Get Clipboard Content

```bash
curl http://host.docker.internal:9999/clipboard
```

### Set Clipboard Content

```bash
echo "hello world" | curl -X POST -d @- http://host.docker.internal:9999/clipboard
```

### Health Check

```bash
curl http://host.docker.internal:9999/health
```

## Docker Integration

### Shell Aliases

The Docker container automatically includes these aliases:

```bash
# Copy to host clipboard
some-command | pbcopy

# Paste from host clipboard
pbpaste
```

### Neovim Integration

Neovim is automatically configured to use the clipboard bridge. Simply use:

- `"+y` to yank to host clipboard
- `"+p` to paste from host clipboard

The configuration is loaded from `~/.config/nvim/clipboard-bridge.lua` when `RUNNING_IN_DOCKER=true`.

## Features

- **TCP-based**: Survives host sleep/wake cycles automatically
- **Simple HTTP API**: Easy to debug with standard tools
- **No file permissions**: No socket file cleanup needed
- **Health endpoint**: Monitor bridge availability

## Troubleshooting

### Bridge unreachable after host sleep

TCP automatically handles reconnection - just retry your clipboard operation.

### "Connection refused" error

Make sure:
1. The bridge is running on the host: `ps aux | grep clipboard-bridge`
2. The bridge is listening on port 9999: `lsof -i :9999`
3. The container can reach the host: `curl http://host.docker.internal:9999/health`

### Neovim not syncing clipboard

Check that `RUNNING_IN_DOCKER` environment variable is set:

```bash
echo $RUNNING_IN_DOCKER  # Should print: true
```

Verify the Neovim config is loaded:

```vim
:echo vim.g.clipboard
```

## macOS Launch Agent Setup (Optional Auto-Start)

To automatically start the clipboard bridge on login, create:

```
~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist
```

With contents:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.localhost.clipboard-bridge</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/clipboard-bridge</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/clipboard-bridge.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/clipboard-bridge.err</string>
</dict>
</plist>
```

Then load it:

```bash
launchctl load ~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist
```
