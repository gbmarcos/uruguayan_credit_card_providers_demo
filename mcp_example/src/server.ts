/**
 * MCP Server with Flutter Widget Integration
 *
 * This server implements the Model Context Protocol (MCP) to enable
 * ChatGPT to display and interact with a Flutter web application.
 *
 * Features:
 * - Session management with UUID-based session IDs
 * - Server-Sent Events (SSE) for real-time communication
 * - Static asset serving for Flutter web builds
 * - Health monitoring endpoint
 *
 * Architecture:
 * - Uses StreamableHTTPServerTransport for bidirectional communication
 * - Maintains persistent session state across multiple requests
 * - Serves Flutter application as an MCP UI resource
 *
 * @see https://modelcontextprotocol.io
 */

// ============================================================================
// Dependencies
// ============================================================================

import "dotenv/config";
import express from "express";
import cors from "cors";
import path from "path";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { randomUUID } from "crypto";
import { readFileSync } from "fs";
import { z } from "zod";

// ============================================================================
// Configuration
// ============================================================================

/**
 * Server port - defaults to 8000 if not specified in environment
 */
const PORT = process.env.PORT || 8000;

/**
 * CDN URL for serving Flutter assets
 * Required for proper asset loading in the Flutter web application
 */
const CDN_URL = process.env.CDN_URL;

/**
 * Path to Flutter build output assets
 */
const FLUTTER_ASSETS_PATH = path.resolve("../build/web/assets");

/**
 * Path to Flutter build output favicon.png
 */
const FLUTTER_FAVICON_PATH = path.resolve("../build/web/icons/Icon-192.png");

/**
 * Pre-load the main Dart JavaScript bundle
 * This is injected into the HTML template for better performance
 */
const MAIN_DART_JS = readFileSync("../build/web/main.dart.js", "utf8");

// ============================================================================
// Express Application Setup
// ============================================================================

const app = express();

/**
 * Configure CORS middleware
 * Allows cross-origin requests from any origin and exposes MCP session headers
 */
app.use(
  cors({
    origin: "*",
    exposedHeaders: ["Mcp-Session-Id"],
    allowedHeaders: ["Content-Type", "mcp-session-id"],
  })
);

/**
 * Serve Flutter static assets (fonts, shaders, manifests, etc.)
 */
app.use("/assets", express.static(FLUTTER_ASSETS_PATH));

app.use("/favicon.png", express.static(FLUTTER_FAVICON_PATH));


// ============================================================================
// Session Management
// ============================================================================

/**
 * Active transport sessions mapped by session ID
 * Each session maintains its own MCP transport instance
 */
const transports: { [sessionId: string]: StreamableHTTPServerTransport } = {};

// ============================================================================
// MCP Server Factory
// ============================================================================

/**
 * Creates and configures an MCP server instance
 *
 * The server exposes:
 * - A UI resource containing the Flutter web application
 * - A tool for displaying the Flutter app in ChatGPT
 *
 * @returns Configured McpServer instance
 */
function createMcpServer(): McpServer {
  const server = new McpServer({
    name: "theme-demo-server",
    version: "1.0.0",
  });

  /**
   * Register the Flutter widget as an MCP UI resource
   *
   * The resource uses the Skybridge HTML format, which allows embedding
   * interactive web applications within ChatGPT's interface.
   *
   * Components:
   * - Root div: Container for the Flutter application
   * - assetBase meta tag: Tells Flutter where to load assets from
   * - Inline script: The compiled Dart-to-JavaScript bundle
   */
  server.registerResource(
    "safe_credit-card-providers-widget",
    "ui://widget/safe_credit-card-providers.html",
    {},
    async () => ({
      contents: [
        {
          uri: "ui://widget/safe_credit-card-providers.html",
          mimeType: "text/html+skybridge",
          text: `
        <div id="safe_credit-card-providers-root"></div>
        <meta name="assetBase" content="${CDN_URL}">
        <script>${MAIN_DART_JS}</script>
        `.trim(),
          _meta: {
            "openai/widgetPrefersBorder": true,
          },
        },
      ],
    })
  );

  /**
   * Register the safe_credit-card-providers-tool tool
   *
   * This tool allows ChatGPT to display the Safe Credit Card Providers information.
   * When invoked, it returns a reference to the UI resource defined above.
   *
   * Metadata:
   * - outputTemplate: Links to the UI resource
   * - toolInvocation states: Provides user-friendly feedback during invocation
   */
  server.registerTool(
    "safe_credit-card-providers-tool",
    {
      title: "Show Safe Credit Card Providers information",
      _meta: {
        "openai/outputTemplate": "ui://widget/safe_credit-card-providers.html",
        "openai/widgetDescription": "Shows an interactive safe credit card providers carousel. When an user asks for safe credit card providers at Uruguay, this widget will be displayed.",
        "openai/toolInvocation/invoking": "Displaying the app",
        "openai/toolInvocation/invoked": "Displayed the app",
        "openai/widgetAccessible": true,
        "openai/resultCanProduceWidget": true,
      },
      inputSchema: { tasks: z.string() },
    },
    async () => {
      return {
        content: [{ type: "text", text: "Displayed the information!" }],
        structuredContent: {},
      };
    }
  );



  console.log(
    "🔧 MCP Server configured with safe_credit-card-providers-tool"
  );
  return server;
}

// ============================================================================
// HTTP Endpoints
// ============================================================================

/**
 * POST /mcp - Handle client-to-server MCP requests
 *
 * This endpoint manages the bidirectional communication between ChatGPT
 * and the MCP server. It handles:
 * - Session creation and reuse
 * - MCP transport lifecycle
 * - Request forwarding to the MCP server
 *
 * Flow:
 * 1. Extract or create session ID
 * 2. Reuse existing transport or create new one
 * 3. Forward request to MCP transport
 * 4. Return JSON-RPC 2.0 formatted response
 *
 * @param req Express request object
 * @param res Express response object
 */
app.post("/mcp", async (req, res) => {
  const sessionId = req.headers["mcp-session-id"] as string | undefined;
  let transport: StreamableHTTPServerTransport;

  try {
    if (sessionId && transports[sessionId]) {
      // Reuse existing transport for this session
      transport = transports[sessionId];
      console.log(`♻️  Reusing transport for session: ${sessionId}`);
    } else {
      // Create new transport for first-time or expired sessions
      console.log("🆕 Creating new transport");

      transport = new StreamableHTTPServerTransport({
        sessionIdGenerator: () => randomUUID(),
        onsessioninitialized: (newSessionId) => {
          // Store transport for future requests
          transports[newSessionId] = transport;
          console.log(`✅ Session initialized: ${newSessionId}`);
        },
      });

      // Clean up transport when session ends
      transport.onclose = () => {
        if (transport.sessionId) {
          delete transports[transport.sessionId];
          console.log(
            `🗑️  Transport closed for session: ${transport.sessionId}`
          );
        }
      };

      // Create and connect MCP server to this transport
      const mcpServer = createMcpServer();
      await mcpServer.connect(transport);
      console.log("🔗 MCP Server connected to transport");
    }

    // Forward request to MCP transport
    await transport.handleRequest(req, res, req.body);
  } catch (error) {
    console.error("❌ Error handling MCP request:", error);

    // Return JSON-RPC 2.0 error response if headers not yet sent
    if (!res.headersSent) {
      res.status(500).json({
        jsonrpc: "2.0",
        error: {
          code: -32603,
          message: "Internal server error",
        },
        id: null,
      });
    }
  }
});

/**
 * GET /mcp - Handle server-to-client notifications via Server-Sent Events (SSE)
 *
 * Establishes a persistent connection for the server to push updates
 * to the client. This enables real-time communication from the MCP
 * server to ChatGPT.
 *
 * Requirements:
 * - Valid mcp-session-id header
 * - Active session in transports map
 *
 * @param req Express request object
 * @param res Express response object
 */
app.get("/mcp", async (req, res) => {
  const sessionId = req.headers["mcp-session-id"] as string | undefined;

  if (!sessionId || !transports[sessionId]) {
    res.status(400).send("Invalid or missing session ID");
    return;
  }

  const transport = transports[sessionId];
  console.log(`📡 SSE connection for session: ${sessionId}`);
  await transport.handleRequest(req, res);
});

/**
 * DELETE /mcp - Handle session termination
 *
 * Allows the client to explicitly terminate an active session.
 * The transport's onclose handler will clean up associated resources.
 *
 * Requirements:
 * - Valid mcp-session-id header
 * - Active session in transports map
 *
 * @param req Express request object
 * @param res Express response object
 */
app.delete("/mcp", async (req, res) => {
  const sessionId = req.headers["mcp-session-id"] as string | undefined;

  if (!sessionId || !transports[sessionId]) {
    res.status(400).send("Invalid or missing session ID");
    return;
  }

  const transport = transports[sessionId];
  console.log(`🛑 Session termination requested: ${sessionId}`);
  await transport.handleRequest(req, res);
});

/**
 * GET /health - Health check endpoint
 *
 * Returns server status and metrics for monitoring purposes.
 *
 * Response includes:
 * - Server status
 * - Current timestamp
 * - Number of active sessions
 *
 * @param req Express request object
 * @param res Express response object
 */
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    activeSessions: Object.keys(transports).length,
  });
});

/**
 * GET / - Root endpoint with API information
 *
 * Provides server metadata and available endpoints.
 * Useful for API discovery and documentation.
 *
 * @param req Express request object
 * @param res Express response object
 */
app.get("/", (req, res) => {
  res.json({
    name: "Theme Demo MCP Server",
    version: "1.0.0",
    endpoints: {
      mcp: "/mcp",
      widget: "/widget/",
      health: "/health",
    },
    documentation: "https://modelcontextprotocol.io",
  });
});

// ============================================================================
// Server Startup
// ============================================================================

/**
 * Start the Express server and listen for incoming connections
 *
 * The server will:
 * - Listen on the configured PORT
 * - Display connection information
 * - Provide cloudflared tunnel instructions for exposing to ChatGPT
 */
app.listen(PORT, () => {
  console.log("═══════════════════════════════════════════════════════");
  console.log("🚀 MCP Server with Flutter Widget");
  console.log("═══════════════════════════════════════════════════════");
  console.log(`📍 Server URL:     http://localhost:${PORT}`);
  console.log(`🔧 MCP Endpoint:   http://localhost:${PORT}/mcp`);
  console.log(`📦 Assets:         http://localhost:${PORT}/assets/`);
  console.log(`❤️  Health Check:   http://localhost:${PORT}/health`);
  console.log("═══════════════════════════════════════════════════════");
  console.log("");
  console.log("🌐 To expose server to ChatGPT, use cloudflared:");
  console.log(
    `   cloudflared tunnel --protocol http2 --url http://localhost:${PORT}`
  );
  console.log("");
  console.log("💡 After starting cloudflared:");
  console.log("   1. Copy the generated *.trycloudflare.com URL");
  console.log("   2. Set CDN_URL in .env to that URL");
  console.log("   3. Add the server URL to ChatGPT settings");
  console.log("");
  console.log("✨ Ready to accept connections!");
});
