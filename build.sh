#!/usr/bin/env bash

if [[ ! -f ~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist ]]; then
	(
		set -e
		cd ./tools/clipboard-bridge/
		go install
		cat <<EOF >~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.localhost.clipboard-bridge</string>
		<key>ProgramArguments</key>
		<array>
			<string>$(go env GOPATH)/bin/clipboard-bridge</string>
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
EOF
		chmod 0644 ~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist
		launchctl unload ~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist >/dev/null 2>&1 || true
		launchctl load ~/Library/LaunchAgents/com.localhost.clipboard-bridge.plist
	)
fi
docker build --no-cache --build-arg USER_ID="$(id -u)" --build-arg GROUP_ID="$(id -g)" -t claudecode .
