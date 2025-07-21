# Cursor Agent MCP Notification Server

A Model Context Protocol (MCP) server that enables AI agents to send system notifications to users on macOS.

<img width="1294" height="900" alt="image" src="https://github.com/user-attachments/assets/23aaa334-daf6-4cdd-b0e4-e90c0f34aabc" />

## Overview

This MCP server provides a `send_notification` tool that allows AI agents to send native macOS notifications with custom titles, subtitles, and messages. It uses a Swift-based notification app to ensure proper integration with the macOS notification system.

## Features

- **Native macOS Notifications**: Sends notifications through the system notification center
- **MCP Integration**: Works seamlessly with any MCP-compatible AI agent or client
- **Customizable Content**: Supports title, subtitle, and message body
- **Error Handling**: Provides clear feedback on success or failure
- **Swift Backend**: Uses a compiled Swift app for reliable notification delivery

## Requirements

- macOS (required for system notifications)
- Node.js or Bun
- Built Swift notification app

## Usage

```json
  "mcpServers": {
    "cursor-agent-notifier": {
      "command": "npx",
      "args": ["cursor-agent-notifier@latest"]
    }
  }
```

## License

MIT
