#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import path from "path";
import util from "util";
import { execFile as execFileSync } from "child_process";

const execFile = util.promisify(execFileSync);

const server = new McpServer({
  name: "notification-server",
  version: "1.0.0",
});

server.registerTool(
  "send_notification",
  {
    title: "Send Notification",
    description: "Send a system notification to the user",
    inputSchema: {
      title: z.string().describe("The title of the notification"),
      subtitle: z.string().describe("The subtitle of the notification"),
      message: z.string().describe("The message body of the notification"),
    },
  },
  async ({ title, subtitle, message }) => {
    try {
      const notifier = path.join(
        __dirname,
        '../dist/cursor-agent-notifier.app/Contents/MacOS/cursor-agent-notifier'
      );

      const { stdout, stderr } = await execFile(notifier, [
        '-title',
        title,
        '-subtitle',
        subtitle,
        '-message',
        message,
      ]);

      if (stderr) {
        return {
          content: [
            {
              type: "text",
              text: `❌ Failed to send notification: ${stderr}`,
            },
          ],
          isError: true,
        };
      }

      return {
        content: [
          {
            type: "text",
            text: `✅ Notification sent successfully!\n\nTitle: "${title}"\nSubtitle: "${subtitle}"\nMessage: "${message}"\nOutput: ${stdout || 'Notification sent'}`,
          },
        ],
      };
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : "Unknown error occurred";

      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to send notification: ${errorMessage}`,
          },
        ],
        isError: true,
      };
    }
  }
);

async function main() {
  const transport = new StdioServerTransport();

  await server.connect(transport);

  console.error("🔔 MCP Notification Server started successfully");
  console.error("📡 Listening for MCP requests via stdio...");
}

main().catch((error) => {
  console.error("❌ Failed to start MCP server:", error);
  process.exit(1);
});
