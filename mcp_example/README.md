# MCP Server with Flutter Widget Integration

A Model Context Protocol (MCP) server that enables ChatGPT to display and interact with Flutter web applications.

## 🚀 Overview

This project implements an MCP server that exposes a Flutter web application as a tool within ChatGPT. When invoked, ChatGPT can display the Flutter app directly in its interface, enabling rich, interactive experiences beyond traditional text responses.

### Key Features

- **MCP Protocol Implementation**: Full implementation of the Model Context Protocol for ChatGPT integration
- **Session Management**: UUID-based session tracking with automatic cleanup
- **Server-Sent Events (SSE)**: Real-time bidirectional communication
- **Flutter Web Hosting**: Serves Flutter assets and compiled Dart code
- **Health Monitoring**: Built-in health check endpoint for monitoring
- **Cloudflared Integration**: Easy tunneling for public access

## 📋 Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- cloudflared CLI tool
- Flutter project built for web

## 🛠️ Installation

1. **Install dependencies**:
```bash
npm install
```

2. **Build the Flutter application**:
```bash
cd ../example
flutter build web
cd ../mcp_example
```

3. **Configure environment variables**:
```bash
# Create .env file
cp .env.example .env

# Edit .env and set:
PORT=8000
CDN_URL=https://your-tunnel-url.trycloudflare.com
```

## 🏃 Running the Server

### Development Mode

```bash
npm run dev
```

This will start the server with hot-reloading enabled.

### Production Mode

```bash
# Build TypeScript to JavaScript
npm run build

# Start the server
npm start
```

### Exposing to ChatGPT

To make the server accessible to ChatGPT, use cloudflared to create a secure tunnel:

```bash
cloudflared tunnel --protocol http2 --url http://localhost:8000
```

**Important**: 
1. Copy the generated `*.trycloudflare.com` URL
2. Update the `CDN_URL` in your `.env` file
3. Restart the server
4. Add the server URL to ChatGPT's MCP settings

## 📁 Project Structure

```
mcp_example/
├── src/
│   └── server.ts          # Main MCP server implementation
├── dist/                  # Compiled JavaScript output
├── node_modules/          # Dependencies
├── .env                   # Environment configuration
├── package.json           # Project metadata and scripts
├── tsconfig.json          # TypeScript configuration
└── README.md             # This file
```

## 🔌 API Endpoints

### MCP Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/mcp` | Handle client-to-server MCP requests |
| GET | `/mcp` | Establish SSE connection for server-to-client notifications |
| DELETE | `/mcp` | Terminate an active session |

All MCP endpoints require the `mcp-session-id` header (except initial POST).

### Utility Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information and documentation |
| GET | `/health` | Health check with active session count |
| GET | `/assets/*` | Serve Flutter static assets |

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `8000` |
| `CDN_URL` | Public URL for asset loading | Required |

### TypeScript Configuration

The project uses strict TypeScript settings:
- `verbatimModuleSyntax`: Enforces type-only imports
- `esModuleInterop`: ES module compatibility
- `strict`: All strict type checking options enabled

## 📊 Session Management

The server maintains a session-based architecture:

1. **Session Creation**: New sessions are created on first POST request
2. **Session Reuse**: Subsequent requests with valid session ID reuse existing transport
3. **Session Cleanup**: Sessions are automatically cleaned up when closed
4. **Session Monitoring**: Active session count available via `/health` endpoint

## 🔐 Security Considerations

- **CORS**: Currently set to allow all origins (`*`). Restrict in production.
- **Session IDs**: Generated using cryptographically secure UUIDs
- **Error Handling**: JSON-RPC 2.0 compliant error responses
- **Cloudflared**: Provides secure tunneling without exposing ports

## 🧪 Testing

### Health Check

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-11-03T12:00:00.000Z",
  "activeSessions": 0
}
```

### MCP Tool Invocation

The server exposes the `flutter-demo` tool, which can be invoked through ChatGPT to display the Flutter application.

## 📚 Technical Details

### MCP Resource Registration

The Flutter app is registered as a UI resource with the MIME type `text/html+skybridge`. The resource includes:
- Root div container (`flutter-demo-root`)
- Asset base URL metadata
- Inline compiled Dart JavaScript

### Transport Layer

Uses `StreamableHTTPServerTransport` from the MCP SDK, which implements:
- JSON-RPC 2.0 protocol
- Bidirectional communication
- Session management
- Error handling

## 🤝 Integration with ChatGPT

1. **Start the server** and cloudflared tunnel
2. **Add to ChatGPT**:
   - Go to ChatGPT Settings → Integrations
   - Add new MCP server
   - Enter your cloudflare tunnel URL
3. **Invoke the tool**: Ask ChatGPT to "show the flutter demo"

## 📝 Development Notes

### Code Style

- **Documentation**: Comprehensive JSDoc comments for all functions
- **Organization**: Logical sections separated by comment dividers
- **Type Safety**: Strict TypeScript with explicit type annotations
- **Error Handling**: Graceful error handling with logging

### Logging

The server uses emoji-prefixed console logging for better readability:
- 🆕 New session creation
- ♻️ Session reuse
- 🗑️ Session cleanup
- 📡 SSE connections
- ❌ Errors
- ✅ Success operations

## 🐛 Troubleshooting

### Assets Not Loading

- Verify `CDN_URL` in `.env` matches your cloudflared tunnel URL
- Ensure Flutter project is built with `flutter build web`
- Check browser console for asset loading errors

### Session Errors

- Verify `mcp-session-id` header is being sent
- Check server logs for session creation/cleanup
- Restart server to clear all sessions

### Connection Issues

- Ensure cloudflared tunnel is running
- Verify firewall allows HTTP/2 connections
- Check ChatGPT MCP server URL is correct

## 📖 Resources

- [Model Context Protocol Documentation](https://modelcontextprotocol.io)
- [MCP SDK GitHub](https://github.com/modelcontextprotocol/sdk)
- [Flutter Web Documentation](https://flutter.dev/web)
- [Cloudflared Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps)

## 📄 License

See the main project LICENSE file.

## 🤝 Contributing

Contributions are welcome! Please ensure:
- Code follows the existing style
- All functions are documented
- TypeScript types are explicit
- Tests pass (when available)

---

**Built with ❤️ using the Model Context Protocol**

