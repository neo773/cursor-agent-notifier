import { test, expect } from "bun:test";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";

test("MCP notification server", async () => {
  const transport = new StdioClientTransport({
    command: "bun",
    args: ["run", "dist/index.js"],
  });

  const client = new Client({
    name: "test-client",
    version: "1.0.0",
  });

  try {
    await client.connect(transport);
    const tools = await client.listTools();

    expect(tools.tools).toHaveLength(1);
    expect(tools.tools[0]?.name).toBe("send_notification");

    const result = (await client.callTool({
      name: "send_notification",
      arguments: {
        title: "MCP Test",
        subtitle: "This is a test notification from your MCP server!",
        message: "This is a test notification from your MCP server!",
      },
    })) as CallToolResult;

    expect(result.content).toHaveLength(1);
    expect(result.content[0]?.text).toContain(
      "✅ Notification sent successfully!"
    );

    const result2 = (await client.callTool({
      name: "send_notification",
      arguments: {
        title: "MCP Test 2",
        message: "Another test notification with different settings!",
        subtitle: "This is a test notification from your MCP server!",
        wait: false,
      },
    })) as CallToolResult;

    expect(result2.content).toHaveLength(1);
    expect(result2.content[0]?.text).toContain(
      "✅ Notification sent successfully!"
    );
  } catch (error) {
    throw error;
  } finally {
    await client.close();
  }
});
