# Credit Card Providers Demo

This is a demonstration application designed to showcase Flutter web app integration with ChatGPT through the Model Context Protocol (MCP).

## Overview

The project consists of a Flutter web application that serves as a product feed interface, which can be accessed and controlled by ChatGPT via an MCP server. This demonstrates how conversational AI can interact with web applications through structured protocols.

## Prerequisites

- Flutter SDK installed and configured
- Node.js and npm
- Cloudflared CLI tool
- ChatGPT with developer mode enabled

## Setup and Execution

Follow these steps to run the application and connect it to ChatGPT:

### 1. Build the Flutter Web Application

First, compile the Flutter application in debug mode:

```bash
flutter build web --debug
```

This will generate the web build artifacts in the `build/web` directory.

### 2. Expose Local Server with Cloudflared

Use Cloudflared to create a secure tunnel and expose your localhost to the internet:

```bash
cloudflared tunnel --url http://localhost:8080
```

Cloudflared will generate a public URL (e.g., `https://xxx.trycloudflare.com`). Keep this URL handy for the next step.

### 3. Configure Environment Variables

Navigate to the `mcp_example` directory and update the environment variables:

```bash
cd mcp_example
```

Edit your environment configuration file (e.g., `.env` or environment configuration) and set the following variables:

- `CDN_URL`: Set this to the Cloudflared URL generated in step 2
- `PORT`: Set this to `8000`

Example:
```
CDN_URL=https://xxx.trycloudflare.com
PORT=8000
```

### 4. Start the MCP Server

From the `mcp_example` directory, start the development server:

```bash
npm run dev
```

This will launch the MCP server that bridges communication between ChatGPT and your Flutter application.

### 5. Connect MCP to ChatGPT

Follow the official [OpenAI Apps SDK documentation](https://developers.openai.com/apps-sdk) to connect your MCP server to ChatGPT. This typically involves:

- Configuring the MCP endpoint in your ChatGPT settings
- Authenticating the connection
- Verifying the integration is working correctly

## Architecture

The application demonstrates a three-tier architecture:
- **Frontend**: Flutter web application serving the UI
- **MCP Server**: Node.js server implementing the Model Context Protocol
- **Integration Layer**: Connection between ChatGPT and the MCP server

## Troubleshooting

- Ensure all ports are available and not blocked by firewalls
- Verify that the Cloudflared tunnel remains active during the entire session
- Check that environment variables are correctly set before starting the MCP server
- Review server logs in the `mcp_example` directory for any connection issues

## License

This is a demonstration project for educational purposes.

