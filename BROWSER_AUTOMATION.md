# TmuxAI Browser Automation with Playwright MCP

## Overview

TmuxAI v2.4.0 now includes browser automation capabilities through Playwright MCP (Model Context Protocol) server integration. This allows you to research solutions, browse documentation, and gather information from trusted web sources directly from your terminal session.

## Features

### ✅ Safe Browser Operations
- **Navigate** to websites (GitHub, Stack Overflow, documentation sites)
- **Take screenshots** and page snapshots
- **Extract content** from web pages
- **Search within pages** for specific information
- **Scroll and wait** for dynamic content loading

### 🚫 Security Restrictions
- **No form filling** or data submission
- **No file downloads** or uploads
- **No login attempts** or password operations
- **No direct clicking** on interactive elements
- **Domain restrictions** to trusted sources only

## Trusted Domains

Browser automation is restricted to these trusted sources:
- **GitHub.com** - Repository browsing, issue tracking, documentation
- **Stack Overflow** - Solution research and troubleshooting
- **Official Documentation** - Docker, Kubernetes, Node.js, Python
- **Package Repositories** - npm, PyPI, official package docs

## Installation

The browser automation is automatically installed when you run the TmuxAI installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh | bash
```

### What Gets Installed

1. **Node.js** (if not present) - Required for Playwright MCP server
2. **Playwright MCP Server** - Installed locally in `~/.config/tmuxai/mcp/playwright/`
3. **Chromium Browser** - Headless browser for automation (installed in background)
4. **Enhanced Configuration** - Updated TmuxAI config with browser automation settings

## Usage Examples

### Research Requests
```bash
tmuxai
"Research Docker best practices on GitHub"
"Find Kubernetes troubleshooting guides online"  
"Look up this error message on Stack Overflow"
"Browse Node.js documentation for this API"
```

### Automatic Error Research
When TmuxAI encounters errors with non-zero exit codes, it can automatically research solutions online:

```bash
# After a failed command
npm install  # fails with error
# TmuxAI automatically searches for the error on Stack Overflow and GitHub
```

### Documentation Browsing
```bash
"Check official Docker documentation for multi-stage builds"
"Find Python asyncio examples on GitHub"
"Look up Kubernetes ingress configuration guide"
```

## Technical Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   TmuxAI        │◄──►│  Playwright      │◄──►│   Browser       │
│  (Devstral AI)  │    │  MCP Server      │    │  (Headless)     │
│                 │    │                  │    │                 │
│ • Tool calling  │    │ • Accessibility  │    │ • Web pages     │
│ • JSON-RPC      │    │   snapshots      │    │ • DOM access    │
│ • Structured    │    │ • No vision      │    │ • Screenshots   │
│   commands      │    │   models needed  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Components

- **TmuxAI Core**: Existing terminal AI assistant with Devstral model
- **Playwright MCP Server**: Browser automation service (separate Node.js process)
- **Configuration Bridge**: YAML settings connecting TmuxAI to MCP server
- **Security Layer**: Command filtering and domain restrictions

### File Structure
```
~/.config/tmuxai/
├── config.yaml              # Main configuration with MCP settings
├── mcp/
│   └── playwright/
│       ├── package.json      # Playwright MCP dependencies
│       ├── node_modules/     # Local installation
│       └── playwright.config.js
└── backups/                  # Configuration backups
```

## Configuration

The browser automation is configured in `~/.config/tmuxai/config.yaml`:

### MCP Server Settings
```yaml
mcp_servers:
  playwright:
    enabled: true
    command: "npx"
    args: [
      "@playwright/mcp@latest",
      "--headless",
      "--allowed-origins", "github.com;stackoverflow.com;docs.docker.com;kubernetes.io;nodejs.org;python.org",
      "--timeout-navigation", "30000",
      "--timeout-action", "10000"
    ]
    working_directory: "~/.config/tmuxai/mcp/playwright"
    auto_start: true
    restart_on_failure: true
```

### Whitelisted Browser Commands
```yaml
whitelist_patterns:
  - "^playwright_navigate .*"     # Navigate to websites
  - "^playwright_snapshot .*"     # Take page snapshots
  - "^playwright_screenshot .*"   # Take screenshots
  - "^playwright_extract .*"      # Extract page content
  - "^playwright_search .*"       # Search within pages
  - "^playwright_scroll .*"       # Scroll page content
  - "^playwright_wait .*"         # Wait for elements
  - "^playwright_evaluate .*"     # Evaluate JavaScript (read-only)
```

### Blacklisted Dangerous Operations
```yaml
blacklist_patterns:
  - "^playwright_click .*"        # Block direct clicking
  - "^playwright_fill .*"         # Block form filling
  - "^playwright_submit .*"       # Block form submission
  - "^playwright_download .*"     # Block file downloads
  - "^playwright_upload .*"       # Block file uploads
  - ".*login.*"                  # Block login attempts
  - ".*password.*"               # Block password operations
```

## Troubleshooting

### Browser Automation Not Working
1. Check if Node.js is installed: `node --version`
2. Verify MCP server installation: `ls ~/.config/tmuxai/mcp/playwright/`
3. Test Playwright MCP: `cd ~/.config/tmuxai/mcp/playwright && npx @playwright/mcp@latest --help`

### Browser Binary Issues
```bash
# Manually install browser binaries if needed
cd ~/.config/tmuxai/mcp/playwright
npx playwright install chromium
```

### Configuration Issues
```bash
# Check TmuxAI configuration
cat ~/.config/tmuxai/config.yaml | grep -A 20 mcp_servers

# Restart TmuxAI session
exit  # from current session
tmuxai  # start new session
```

## Security Model

### Read-Only Operations
- Browser automation focuses exclusively on information gathering
- No data submission or modification capabilities
- Headless browser mode prevents user interaction requirements

### Domain Whitelisting
- Only trusted domains are accessible
- Blocks access to social media, e-commerce, or personal sites
- Prevents inadvertent navigation to malicious content

### Process Isolation
- MCP server runs as separate process from TmuxAI core
- Browser crashes don't affect terminal assistant functionality
- Easy to disable by setting `enabled: false` in configuration

## Performance

### Resource Usage
- **TmuxAI Core**: ~50-100MB (unchanged)
- **MCP Server**: ~20-50MB when active
- **Browser Instance**: ~100-200MB per session
- **Total Added**: ~120-250MB for browser automation

### Optimization
- Browser instances are created on-demand
- Automatic cleanup after research sessions
- Configurable timeouts prevent hanging operations
- Background browser installation during setup

## Updates and Maintenance

### Updating Playwright MCP
```bash
cd ~/.config/tmuxai/mcp/playwright
npm update @playwright/mcp@latest
```

### Cleaning Up
```bash
# Remove all browser automation (if not needed)
rm -rf ~/.config/tmuxai/mcp/

# Or just disable in config
# Set mcp_servers.playwright.enabled: false
```

### Logs and Debugging
```bash
# Check MCP server logs
tail -f ~/playwright-mcp-server.log

# Enable debug mode in TmuxAI config
# Set debug: true in ~/.config/tmuxai/config.yaml
```

## Comparison with Previous Version

| Feature | TmuxAI v2.3.0 | TmuxAI v2.4.0 (Browser Automation) |
|---------|---------------|-------------------------------------|
| Terminal Commands | ✅ Full support | ✅ Full support |
| AI Analysis | ✅ Local analysis only | ✅ Enhanced with web research |
| Error Troubleshooting | ✅ Basic suggestions | ✅ Online solution research |
| Documentation Access | ❌ Manual browser required | ✅ Automatic browsing |
| GitHub Repository Research | ❌ Not available | ✅ Automated browsing |
| Stack Overflow Integration | ❌ Not available | ✅ Error solution lookup |
| Resource Usage | ~100MB | ~250MB (with browser) |

## Conclusion

TmuxAI v2.4.0 with Playwright MCP integration transforms the terminal assistant from a local command helper into a comprehensive research and troubleshooting platform. The browser automation capabilities maintain the security-first approach while significantly expanding the AI's ability to assist with real-world system administration and development tasks.

The integration is designed to be seamless, secure, and optional - users who don't need browser automation can easily disable it while maintaining full terminal functionality.