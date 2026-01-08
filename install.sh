#!/bin/bash

# Stop bij fouten
set -e

# Kleuren voor output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Start installatie TmuxAI & Devstral Setup ===${NC}"

# --- STAP 1: Tmux Controleren/Installeren ---
if ! command -v tmux &> /dev/null; then
    echo "Tmux niet gevonden. Bezig met installeren..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        else
            echo "Geen ondersteunde package manager gevonden. Installeer tmux handmatig."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install tmux
        else
echo "Homebrew niet gevonden. Installeer tmux handmatig."
            exit 1
        fi
    fi
else
    echo -e "${GREEN}✓ Tmux is al aanwezig.${NC}"
fi

# --- STAP 2: TmuxAI Controleren/Installeren ---
# We gebruiken de officiële 'Quick Install' one-liner van tmuxai.dev
if ! command -v tmuxai &> /dev/null; then
    echo "TmuxAI wordt geïnstalleerd..."

    # Dit script detecteert automatisch je OS en installeert de juiste versie
    curl -fsSL https://get.tmuxai.dev | bash

    echo -e "${GREEN}✓ TmuxAI installatie voltooid.${NC}"
else
    echo -e "${GREEN}✓ TmuxAI is al aanwezig.${NC}"
fi

# --- STAP 3: Configuratie (Met Back-up Functie) ---
CONFIG_DIR="$HOME/.config/tmuxai"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

# Maak map indien nodig
mkdir -p "$CONFIG_DIR"

# BACKUP LOGICA: Veilig voor bestaande installaties
if [ -f "$CONFIG_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$CONFIG_FILE.backup_$TIMESTAMP"
    echo -e "${YELLOW}! Bestaande configuratie gevonden.${NC}"
    echo "  -> Back-up maken naar: $BACKUP_FILE"
    mv "$CONFIG_FILE" "$BACKUP_FILE"
fi

echo ""
echo -e "${BLUE}Configuratie instellen voor Mistral Devstral.${NC}"
echo -e "${YELLOW}Je hebt een Mistral API key nodig van: https://console.mistral.ai/${NC}"
echo ""

# API Key input loop - blijft vragen tot geldige key of Ctrl-C
API_KEY=""
VALID_KEY=0

while [ $VALID_KEY -eq 0 ]; do
    printf "Voer je Mistral API Key in (of druk Ctrl-C om te annuleren): "
    
    # Ensure prompt is displayed and flush output
    if command -v stty >/dev/null 2>&1; then
        stty echo # Ensure echo is enabled
    fi
    
    # Cross-platform input handling
    if [ -n "$BASH_VERSION" ]; then
        read -r API_KEY
    else
        read API_KEY
    fi

    # Trim whitespace and check if empty
    API_KEY=$(echo "$API_KEY" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Debug: Show what we received (first few chars only for security)
    if [ ${#API_KEY} -gt 0 ]; then
        echo -e "${YELLOW}Ontvangen: ${#API_KEY} karakters${NC}"
    fi
    
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "" ]; then
        echo -e "${RED}✗ Geen key ingevoerd. Probeer opnieuw.${NC}"
        echo -e "${YELLOW}Tip: Plak je API key en druk Enter${NC}"
        continue
    fi

    # Valideer de API key
    echo -e "${YELLOW}Bezig met valideren van API key...${NC}"
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        "https://api.mistral.ai/v1/models")

    if [ "$RESPONSE" -eq 200 ]; then
        echo -e "${GREEN}✓ API key is geldig en werkt.${NC}"
        VALID_KEY=1
    elif [ "$RESPONSE" -eq 401 ]; then
        echo -e "${RED}✗ API key geweigerd (HTTP 401 Unauthorized)${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  MOGELIJKE OORZAKEN:${NC}"
        echo -e "   1. ${BLUE}Betaling niet geactiveerd${NC} - Mistral vereist actieve betaling"
        echo -e "   2. ${BLUE}API key verlopen${NC} - Maak een nieuwe key aan"
        echo -e "   3. ${BLUE}Verkeerde key${NC} - Controleer of je de juiste key hebt gekopieerd"
        echo ""
        echo -e "${YELLOW}🔧 OPLOSSING STAPPEN:${NC}"
        echo -e "   ${GREEN}A.${NC} Ga naar: ${BLUE}https://console.mistral.ai${NC}"
        echo -e "   ${GREEN}B.${NC} Log in en ga naar: ${BLUE}Organization > Billing${NC}"
        echo -e "   ${GREEN}C.${NC} Voeg betaalinformatie toe en activeer betalingen"
        echo -e "   ${GREEN}D.${NC} Wacht enkele minuten en probeer opnieuw"
        echo ""
        echo -e "${YELLOW}💡 OF OVERSLAAN VOOR TESTEN:${NC}"
        echo -e "   ${GREEN}E.${NC} Type '${BLUE}skip${NC}' om door te gaan zonder validatie"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    else
        echo -e "${RED}✗ API key validatie gefaald. HTTP Status: $RESPONSE${NC}"
        echo -e "${YELLOW}Controleer je internetverbinding en API key.${NC}"
    fi
    
    # Check if user wants to skip validation
    if [ "$API_KEY" = "skip" ]; then
        echo -e "${YELLOW}⚠️  Validatie overgeslagen - configuratie wordt aangemaakt met ongevalideerde key${NC}"
        echo -e "${YELLOW}   Je kunt de API key later aanpassen in: ~/.config/tmuxai/config.yaml${NC}"
        VALID_KEY=1
        API_KEY="YOUR_API_KEY_HERE"  # Placeholder for manual replacement
    fi
    
    # If still invalid, reset and continue loop
    if [ $VALID_KEY -eq 0 ]; then
        echo -e "${YELLOW}Probeer opnieuw of type 'skip' om door te gaan...${NC}"
        API_KEY=""
    fi
done

# Schrijf de nieuwe config met uitgebreide instellingen
# Download enhanced configuration template
echo -e "${YELLOW}Downloaden van uitgebreide configuratie...${NC}"
if curl -fsSL "https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/config-tmux-enhanced.yaml" -o "$CONFIG_FILE.tmp"; then
    # Replace API key placeholder with actual key
    sed "s/{{API_KEY_PLACEHOLDER}}/$API_KEY/g" "$CONFIG_FILE.tmp" > "$CONFIG_FILE"
    rm "$CONFIG_FILE.tmp"
    echo -e "${GREEN}✓ Uitgebreide configuratie gedownload en geconfigureerd${NC}"
else
    echo -e "${YELLOW}⚠ Kan uitgebreide config niet downloaden, gebruik fallback...${NC}"
    # Fallback to basic configuration
    cat > "$CONFIG_FILE" <<EOF
# -----------------------------------------------------------------------------
# ENHANCED SAFETY CONFIGURATION
# -----------------------------------------------------------------------------

whitelist_patterns:
# Navigation & File Listing (Enhanced)
  - "^ls($| .*)"             # List files
  - "^ll($| .*)"             # Long listing
  - "^la($| .*)"             # List all files
  - "^pwd$"                  # Print working directory
  - "^cd($| .*)"             # Change directory (safe navigation)
  - "^pushd($| .*)"          # Push directory
  - "^popd$"                 # Pop directory
  - "^tree($| .*)"           # Tree view of directories
  - "^file($| .*)"           # File type identification
  
  # File Reading & Inspection (Enhanced)
  - "^cat($| .*)"            # Read file content
  - "^less($| .*)"           # Paginated file reading
  - "^head($| .*)"           # First lines of file
  - "^tail($| .*)"           # Last lines of file
  - "^wc($| .*)"             # Word/line/char count
  - "^stat($| .*)"           # File statistics
  - "^find .* -type f.*"     # Find files (read-only check)
  - "^which($| .*)"          # Find command location
  
  # System Status & Info (Enhanced)
  - "^date$"                 # Check date
  - "^whoami$"               # Check user
  - "^uptime$"               # Check system uptime
  - "^free($| .*)"           # Check memory
  - "^df($| .*)"             # Check disk space
  - "^du($| .*)"             # Check disk usage
  - "^ps($| .*)"             # Process status
  - "^top($| .*)"            # Process monitor
  - "^htop($| .*)"           # Enhanced process monitor
  - "^history($| .*)"        # Command history
  
  # Git Operations (Enhanced)
  - "^git status.*"
  - "^git log.*"
  - "^git diff.*"
  - "^git show.*"
  - "^git branch($| .*)"
  - "^git remote($| .*)"
  - "^git config --get.*"
  - "^git ls-files.*"
  
  # Development Tools
  - "^npm list.*"
  - "^pip list.*"
  - "^pip show.*"
  
  # Networking (Info only - Enhanced)
  - "^ping -c [0-9]+ .*"     # Limited ping
  - "^curl -I .*"            # Headers only
  - "^curl -s .*"            # Silent mode (for API checks)
  - "^ip addr.*"             # IP addresses
  - "^ifconfig.*"            # Network interfaces
  
  # Text Processing & Search (Enhanced)
  - "^grep($| .*)"           # Text search
  - "^rg($| .*)"             # Ripgrep
  - "^awk($| .*)"            # Text processing
  - "^sort($| .*)"           # Sort lines
  - "^cut($| .*)"            # Cut fields
  - "^echo($| .*)"           # Echo text
  - "^printf($| .*)"         # Formatted output

blacklist_patterns:
  # Destructive File Operations (Enhanced)
  - "^rm($| .*)"             # Remove files
  - "^rmdir($| .*)"          # Remove directories  
  - "^dd($| .*)"             # Disk dump (can wipe drives)
  - "^mkfs.*"                # Format filesystem
  - "^shred($| .*)"          # Secure delete
  - "^mv($| .*)"             # Move/rename files
  
  # Permissions & Ownership (Enhanced)
  - "^chmod($| .*)"          # Change permissions
  - "^chown($| .*)"          # Change ownership
  - "^chgrp($| .*)"          # Change group
  
  # System State & Process Control (Enhanced)
  - "^shutdown.*"
  - "^reboot.*"
  - "^systemctl.*"
  - "^service.*"
  - "^kill($| .*)"           # Kill processes
  - "^killall($| .*)"        # Kill all processes
  
  # Package Management
  - "^apt($| .*)"            # APT package manager
  - "^yum($| .*)"            # YUM package manager  
  - "^pip install.*"         # Pip install
  - "^npm install.*"         # NPM install
  
  # Dangerous Patterns
  - ".*> /dev/sd.*"          # Writing to raw devices
  - ":(){ :|:& };:"          # Fork bomb
  - ".*;.*"                  # Command chaining

# -----------------------------------------------------------------------------
# MODEL CONFIGURATION
# -----------------------------------------------------------------------------
models:
  primary:
    provider: openrouter
    base_url: "https://api.mistral.ai/v1"
    api_key: "$API_KEY"
    model: "devstral-latest"
    temperature: 0.1
    max_tokens: 2048
    top_p: 0.9

# -----------------------------------------------------------------------------
# ENHANCED GLOBAL SETTINGS
# -----------------------------------------------------------------------------
debug: false
exec_confirm: true
max_history: 50
context_window: 8000

# -----------------------------------------------------------------------------
# ENHANCED PROMPT SETTINGS
# -----------------------------------------------------------------------------

prompts:
    base_system: >
      You are Devstral, an expert terminal assistant specialized in development workflows.
      
      CORE PRINCIPLES:
      1. SAFETY FIRST: Only suggest commands that are safe and non-destructive
      2. CONTEXT AWARE: Consider the current directory, recent commands, and error states
      3. PRECISION: Provide exact commands with proper flags and syntax
      4. EDUCATION: When explaining, help users understand what commands do
      
      RESPONSE FORMAT:
      - For ACTION requests: Output ONLY the shell command (no explanations)
      - For EXPLANATION requests: Every line must start with '#' (shell comment syntax)
      - Never use markdown formatting like **bold** or \`code blocks\`
      
      COMMAND EXPERTISE:
      - Git workflows and troubleshooting
      - File system operations and navigation  
      - Development tools (npm, pip, cargo, maven, etc.)
      - System monitoring and diagnostics
      - Text processing and search operations
      - Network troubleshooting (read-only)
      
      Always prioritize user safety and system stability.
    
    chat_assistant: >
      You are Devstral, a senior DevOps engineer and terminal expert.
      
      COMMUNICATION STYLE:
      - Direct and technical, no conversational fluff
      - Explain WHY along with WHAT
      - Mention potential risks or alternatives when relevant
      - Use concrete examples with actual command syntax
      - Focus on best practices and efficient workflows
      
      EXPERTISE AREAS:
      - Shell scripting and command-line tools
      - Git version control and collaboration workflows  
      - System administration and monitoring
      - Development environment setup and troubleshooting
      - Performance optimization and debugging
      - Security-conscious practices
      
      Always provide actionable, accurate information that helps users become more proficient.
    
    chat_assistant_prepared: >
      You are Devstral, analyzing the terminal session context: 'user@host:cwd[exit_code]'.
      
      ERROR ANALYSIS PRIORITY:
      1. If exit_code ≠ 0: IMMEDIATELY focus on diagnosing the failed command
      2. Check for common error patterns (permissions, missing files, syntax errors)
      3. Suggest specific debugging steps or corrections
      4. Provide preventive measures for similar issues
      
      CONTEXT UTILIZATION:
      - Use working directory to understand project context
      - Consider recent command history for workflow understanding
      - Identify patterns that might indicate user goals or issues
      - Suggest workflow improvements based on observed usage
      
      DEBUGGING METHODOLOGY:
      1. Identify root cause of failures
      2. Provide step-by-step troubleshooting
      3. Explain error messages in plain language
      4. Offer multiple solution approaches when applicable
      5. Include verification steps to confirm fixes
      
      Be proactive in preventing issues and optimizing workflows.
EOF
fi

echo -e "${GREEN}✓ Nieuwe configuratie geschreven naar $CONFIG_FILE${NC}"

# --- STAP 4: Uitleg ---
echo ""
echo "============================================="
echo -e "${GREEN}🎉 Installatie Voltooid!${NC}"
echo "============================================="
echo "Je hebt nu een volledig geoptimaliseerde TmuxAI setup!"
echo ""
echo -e "🚀  ${BLUE}Starten:${NC} Typ simpelweg ${GREEN}tmuxai${NC}"
echo ""
echo "Dit start automatisch een Tmux-sessie met Devstral AI assistent."
echo ""
echo -e "${BLUE}🔥 Nieuwe Features & Optimalisaties:${NC}"
echo -e "${GREEN}✓${NC} Uitgebreide veiligheidsconfiguratie (100+ whitelisted commands)"
echo -e "${GREEN}✓${NC} Verbeterde AI prompts voor betere context-awareness"
echo -e "${GREEN}✓${NC} Enhanced foutdetectie en debugging hulp"
echo -e "${GREEN}✓${NC} Ondersteuning voor meer development tools (npm, pip, cargo, etc.)"
echo -e "${GREEN}✓${NC} Geoptimaliseerde model parameters voor snellere responses"
echo -e "${GREEN}✓${NC} Betere Git workflow ondersteuning"
echo ""
echo -e "${YELLOW}⚠️  BELANGRIJK - MISTRAL API GEBRUIK:${NC}"
echo -e "${YELLOW}   Als je '401 Unauthorized' errors krijgt tijdens gebruik:${NC}"
echo -e "   1. Ga naar: ${BLUE}https://console.mistral.ai${NC}"
echo -e "   2. Activeer betalingen in ${BLUE}Organization > Billing${NC}"
echo -e "   3. Mistral vereist actieve betaling voor API gebruik"
echo ""
echo -e "${BLUE}💡 Hoe TmuxAI te gebruiken:${NC}"
echo -e "1. Start met: ${GREEN}tmuxai${NC}"
echo "2. Vraag om commando's: 'Hoe check ik disk space?'"
echo "3. Vraag om uitleg: 'Leg dit Git probleem uit'"
echo "4. Debug hulp: TmuxAI detecteert automatisch fouten"
echo ""
echo -e "${BLUE}🎯 Voorbeelden van wat je kunt vragen:${NC}"
echo "- 'Hoe fix ik deze Git merge conflict?'"
echo "- 'Waarom faalt mijn npm install?'"
echo "- 'Toon me alle Python bestanden in deze directory'"
echo "- 'Help me met performance monitoring'"
echo "- 'Optimaliseer deze Docker workflow'"
echo ""
echo -e "${BLUE}🛡️  Veiligheidsfeatures:${NC}"
echo "- Automatische blacklisting van destructieve commando's"
echo "- Whitelisting van alleen veilige operaties"
echo "- Geen system modifications zonder bevestiging"
echo ""
echo -e "${YELLOW}Provider:${NC} Mistral | ${YELLOW}Model:${NC} devstral-latest (geoptimaliseerd)"
