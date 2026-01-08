# 🚀 TmuxAI Enhanced Installer

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/Omaha2002/tmuxai-installer)](https://github.com/Omaha2002/tmuxai-installer/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](#supported-platforms)

## 🤖 What is TmuxAI?

**TmuxAI** is an AI-powered, non-intrusive terminal assistant that works alongside you in a tmux window. Just like a colleague sitting next to you, TmuxAI observes your screen, understands context from what's visible, and helps accordingly.

🔗 **Learn more at [tmuxai.dev](https://tmuxai.dev/)**

This project provides a one-click installer that sets up **TmuxAI** with **Mistral's Devstral model** and an **enhanced, security-focused configuration** for intelligent terminal assistance.

> **🎉 Latest Release: v2.0.0** - Major enhancements with 100+ safe commands, AI persona "Devstral", and context-aware error detection!

---

## 🎯 **What is TmuxAI Enhanced?**

TmuxAI Enhanced transforms your terminal into an AI-powered development environment with:
- **🤖 Devstral AI Assistant**: Professional DevOps engineer persona
- **🛡️ Security-First Approach**: 100+ whitelisted safe commands, comprehensive blacklisting
- **🧠 Context-Aware Intelligence**: Understands your directory, commands, and error states
- **🔧 Development Tools Support**: npm, pip, cargo, maven, composer, and more
- **⚡ Optimized Performance**: Tuned model parameters for focused responses

---

## 🚀 **Quick Start**

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh | bash
```

That's it! The installer will:
1. ✅ Install tmux (if not present)
2. ✅ Install TmuxAI 
3. ✅ Set up enhanced configuration with security patterns
4. ✅ Validate your Mistral API key
5. ✅ Configure optimized AI settings

---

## 📋 **Prerequisites**

### Required
- **Operating System**: Linux (Ubuntu, CentOS, etc.) or macOS
- **Mistral API Key**: Get yours at [console.mistral.ai](https://console.mistral.ai/)
- **Internet Connection**: For downloading components and API validation

### Optional (Auto-installed)
- **tmux**: Installed automatically if not present
- **Package Manager**: `apt-get`, `yum`, or `brew` (detected automatically)

---

## 🛠️ **Detailed Installation Guide**

### Step 1: Get Your Mistral API Key
1. Visit [Mistral AI Console](https://console.mistral.ai/)
2. Sign up or log in to your account
3. **⚠️ CRITICAL**: Navigate to `Organization > Billing` and **activate payments**
   - Mistral requires active payment information to enable API keys
   - You can choose the "Experiment" (free trial) or "Scale" (pay-as-you-go) plan
   - Wait a few minutes after activation
4. Navigate to API Keys section
5. Create a new API key
6. **Copy the key** - you'll need it during installation

### Step 2: Run the Installer

#### Option A: Direct Installation (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh | bash
```

#### Option B: Download and Inspect First (Security-Conscious)
```bash
# Download the installer
wget https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh

# Review the script (always a good practice!)
cat install.sh

# Make executable and run
chmod +x install.sh
./install.sh
```

### Step 3: Follow the Prompts
The installer will:
- Check and install tmux if needed
- Install TmuxAI automatically
- Prompt for your Mistral API key
- Validate the API key against Mistral's servers
- Deploy the enhanced configuration
- Show you how to get started

---

## 🎮 **How to Use TmuxAI**

### Starting TmuxAI
```bash
tmuxai
```
This launches a tmux session with the AI assistant active.

### Basic Usage Examples

#### 🔍 **Getting Command Suggestions**
```bash
# Just ask for what you want to do
"How do I check disk space?"
"Show me all Python files in this directory"
"What's using the most CPU right now?"
```

#### 🧠 **Getting Explanations**
```bash
# Ask for explanations of commands or errors
"Explain what this git error means"
"Why did my npm install fail?"
"What does this bash script do?"
```

#### 🚨 **Automatic Error Detection**
```bash
# When a command fails, TmuxAI automatically helps
$ invalid_command
# Devstral immediately analyzes the failure and suggests fixes
```

#### 💡 **Development Assistance**
```bash
"Help me optimize this Docker build"
"Best way to structure this Python project"
"How to debug this performance issue"
"Set up CI/CD for this repository"
```

---

## ✨ **Key Features**

### 🤖 **Meet "Devstral" - Your AI DevOps Expert**
- **Professional Persona**: Senior DevOps engineer and terminal expert
- **Direct Communication**: No fluff, just technical accuracy
- **Educational Approach**: Explains WHY along with WHAT
- **Best Practices Focus**: Promotes efficient, secure workflows

### 🛡️ **Advanced Security (100+ Safe Commands)**

#### ✅ **Whitelisted Commands Include:**
- **Navigation**: `ls`, `cd`, `pwd`, `tree`, `find`, `locate`
- **File Operations**: `cat`, `less`, `head`, `tail`, `grep`, `stat`
- **Git Operations**: `status`, `log`, `diff`, `show`, `branch`, `blame`
- **Development Tools**: `npm list`, `pip show`, `cargo tree`, `mvn dependency:tree`
- **System Monitoring**: `top`, `ps`, `free`, `df`, `netstat`, `lscpu`
- **Text Processing**: `awk`, `sort`, `cut`, `tr`, `rg`, `ag`

#### 🚫 **Automatically Blocked Dangerous Commands:**
- **File Destruction**: `rm`, `dd`, `shred`, `truncate`
- **System Modification**: `chmod`, `chown`, `systemctl`, `service`
- **Package Installation**: `apt install`, `yum install`, `pip install`
- **Network Security**: `iptables`, `ssh`, `nmap`, `nc`
- **Malicious Patterns**: Fork bombs, dangerous redirections, command chaining

### 🧠 **Context-Aware Intelligence**
- **Directory Understanding**: Recognizes project context and structure
- **Error Analysis**: Automatically prioritizes troubleshooting failed commands
- **Command History**: Learns from your workflow patterns
- **Exit Code Detection**: Immediately helps when commands fail (exit_code ≠ 0)

### ⚡ **Performance Optimizations**
- **Temperature: 0.1** - More focused, consistent responses
- **Max Tokens: 2048** - Adequate response length
- **Context Window: 8000** - Better conversation memory
- **Top-p: 0.9** - Quality nucleus sampling

---

## 🔧 **Configuration**

### Configuration File Location
```bash
~/.config/tmuxai/config.yaml
```

### Enhanced Configuration Features
- **Dual-layer Security**: Whitelist + Blacklist approach
- **Development-Focused**: Supports modern dev tools and workflows
- **Model Optimization**: Tuned parameters for terminal use
- **Session Management**: Auto-save and history retention

### Customization
The installer creates a comprehensive configuration with security patterns. You can:
- **Add safe commands** to the whitelist
- **Modify AI prompts** for your specific use case
- **Adjust model parameters** for different response styles
- **Configure session settings** for your workflow

---

## 🔄 **Upgrading**

### From Previous Versions
Simply run the installer again:
```bash
curl -fsSL https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh | bash
```

The installer will:
- ✅ **Backup your existing configuration** with timestamp
- ✅ **Preserve your API key** automatically  
- ✅ **Deploy new features** and security patterns
- ✅ **Maintain compatibility** with your current setup

---

## 🌍 **Supported Platforms**

### ✅ **Fully Supported**
- **Ubuntu** (18.04+, 20.04, 22.04, 24.04)
- **Debian** (10+, 11, 12)
- **CentOS** (7, 8, Stream)
- **RHEL** (7, 8, 9)
- **Fedora** (Recent versions)
- **macOS** (10.15+, Big Sur, Monterey, Ventura, Sonoma)

### 📦 **Package Managers**
- **apt-get** (Debian/Ubuntu)
- **yum** (CentOS/RHEL)
- **dnf** (Fedora)
- **brew** (macOS)

---

## 🚨 **Troubleshooting**

### Common Issues

#### ❌ **"API key is invalid" or "401 Unauthorized"**
```bash
# Solution 1: ACTIVATE PAYMENTS (Most Common Issue)
# - Visit https://console.mistral.ai/
# - Go to Organization > Billing
# - Add payment information and activate payments
# - Choose "Experiment" (free trial) or "Scale" (pay-as-you-go)
# - Wait 5-10 minutes after activation

# Solution 2: Double-check your API key
# - Visit https://console.mistral.ai/
# - Copy the key exactly as shown
# - Avoid extra spaces or characters

# Solution 3: Test API key manually
curl -H "Authorization: Bearer YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     "https://api.mistral.ai/v1/models"
```

> **🚨 Important**: Mistral requires activated payments even for free trial usage. The most common cause of 401 errors is not having activated billing.

#### ❌ **"tmux command not found" after installation**
```bash
# Solution: Reload your shell
source ~/.bashrc
# or
source ~/.zshrc
# or simply start a new terminal session
```

#### ❌ **"Permission denied" errors**
```bash
# Solution: Ensure you have proper permissions
# The installer may need sudo for package installation
# Your home directory should be writable for config files
```

#### ❌ **macOS: "Homebrew not found"**
```bash
# Solution: Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then run the TmuxAI installer again
```

### Getting Help
1. **Check the logs**: Installation output provides detailed error information
2. **Validate API key**: Use the curl command above to test connectivity
3. **File an issue**: Create a GitHub issue with details about your system and error
4. **Community support**: Join discussions in the repository issues section

---

## 🤝 **Contributing**

We welcome contributions! Here's how you can help:

### 🐛 **Report Bugs**
- Create a [GitHub issue](https://github.com/Omaha2002/tmuxai-installer/issues)
- Include your OS, terminal, and error details
- Provide steps to reproduce the problem

### 💡 **Suggest Features**
- Propose new safe commands for whitelisting
- Suggest AI prompt improvements
- Recommend security pattern enhancements

### 🔧 **Submit Pull Requests**
- Fork the repository
- Create a feature branch
- Test your changes on multiple platforms
- Submit a PR with detailed description

### 📝 **Improve Documentation**
- Help expand usage examples
- Add troubleshooting solutions
- Translate documentation
- Create video tutorials

---

## 📊 **Project Stats**

- **🛡️ Security Patterns**: 100+ whitelisted commands, comprehensive blacklist
- **🧠 AI Intelligence**: Context-aware with professional DevOps persona
- **🌍 Platform Support**: Linux & macOS with major package managers
- **⚡ Performance**: Optimized model parameters for terminal use
- **🔄 Update Mechanism**: Smart configuration deployment with fallback

---

## 🏷️ **Version History**

### v2.0.0 (Latest) - Major Enhancements
- ✨ **AI Persona**: Professional "Devstral" DevOps expert
- 🛡️ **Security**: 100+ whitelisted commands (5x increase)
- 🧠 **Intelligence**: Context-aware error detection and analysis
- ⚡ **Performance**: Optimized model parameters
- 🔧 **Development**: Enhanced support for modern dev tools

### v1.0.0 - Initial Release
- 🚀 **Basic Installation**: tmux + TmuxAI setup
- 🛡️ **Basic Security**: ~20 whitelisted commands
- 🤖 **AI Assistant**: Generic terminal helper
- 📱 **Cross-platform**: Linux and macOS support

---

## 🙏 **Acknowledgments**

- **[Mistral AI](https://mistral.ai/)** - For the powerful Devstral model
- **[TmuxAI Team](https://tmuxai.dev/)** - For the excellent foundation
- **[Tmux](https://github.com/tmux/tmux)** - For the terminal multiplexer
- **Community Contributors** - For feedback, testing, and improvements
- **[Warp AI](https://warp.dev/)** - For development assistance

---

## 📜 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 **Links**

- **🏠 Repository**: [github.com/Omaha2002/tmuxai-installer](https://github.com/Omaha2002/tmuxai-installer)
- **🚀 Latest Release**: [v2.0.0](https://github.com/Omaha2002/tmuxai-installer/releases/tag/v2.0.0)
- **🤖 Mistral AI**: [console.mistral.ai](https://console.mistral.ai/)
- **📚 TmuxAI**: [tmuxai.dev](https://tmuxai.dev/)
- **🔧 Tmux**: [github.com/tmux/tmux](https://github.com/tmux/tmux)

---

<div align="center">

**🎉 Ready to supercharge your terminal with AI?**

```bash
curl -fsSL https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh | bash
```

**Made with ❤️ for developers who love efficient, secure workflows**

</div>