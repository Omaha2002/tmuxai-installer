# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a TmuxAI installation and configuration project that sets up an intelligent terminal assistant using Mistral's Devstral model. The project consists of:

- Installation script for automated TmuxAI setup
- Configuration template for TmuxAI with security patterns
- Safety-focused configuration with command whitelisting/blacklisting

## Architecture

### Core Components

**Installation Script (`install.sh`)**
- Automated installation of tmux and TmuxAI
- API key validation against Mistral API
- Configuration backup and deployment
- Cross-platform support (Linux/macOS)

**Configuration Template (`config-tmux.yaml`)**
- Comprehensive security patterns for command filtering
- Model configuration for Mistral Devstral
- Prompt engineering settings for terminal assistance
- Safety-first approach with explicit whitelisting

### Security Model

The configuration implements a dual-layer security approach:
- **Whitelist patterns**: Explicitly allowed safe commands (read-only operations, navigation, git status)
- **Blacklist patterns**: Explicitly forbidden dangerous commands (file deletion, system modification, permission changes)

## Development Commands

### Installation and Setup
```bash
# Run the installation script
./install.sh

# Start TmuxAI session
tmuxai
```

### Configuration Management
```bash
# Edit TmuxAI configuration
vim ~/.config/tmuxai/config.yaml

# View current TmuxAI configuration
cat ~/.config/tmuxai/config.yaml

# Backup existing configuration (done automatically by install script)
cp ~/.config/tmuxai/config.yaml ~/.config/tmuxai/config.yaml.backup_$(date +%Y%m%d_%H%M%S)
```

### Testing and Validation
```bash
# Test API key validity
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     "https://api.mistral.ai/v1/models"

# Validate configuration syntax
tmuxai --validate-config
```

## Configuration Structure

The TmuxAI configuration follows this hierarchy:

1. **Security Patterns** - Command filtering rules
2. **Model Configuration** - AI provider settings
3. **Global Settings** - Execution and debug options  
4. **Prompt Configuration** - AI behavior definitions

### Key Configuration Sections

**Safety Configuration**: Uses regex patterns to control which terminal commands the AI can suggest or execute. The whitelist approach ensures only explicitly safe commands are allowed.

**Model Settings**: Configured for Mistral's Devstral model via OpenRouter-compatible API, specifically tuned for code assistance.

**Prompt Engineering**: Three distinct prompt modes:
- `base_system`: Strict command-only output mode
- `chat_assistant`: Technical explanations mode
- `chat_assistant_prepared`: Context-aware debugging mode

## Security Considerations

- Never commit API keys to version control
- The configuration includes extensive command blacklisting for system safety
- Installation script validates API keys before deployment
- Automatic backup of existing configurations during updates

## Usage Patterns

The system is designed for:
- Safe terminal command suggestions
- Code explanation and analysis
- Debug assistance with error context
- Git workflow support (read-only operations)
- System monitoring and information gathering

Commands are filtered through regex patterns to ensure the AI cannot suggest destructive operations while maintaining full functionality for development tasks.