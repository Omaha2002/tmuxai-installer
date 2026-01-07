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
    else
        echo -e "${RED}✗ API key is ongeldig of werkt niet. HTTP Status: $RESPONSE${NC}"
        echo -e "${YELLOW}Druk Ctrl-C om het script te stoppen, of probeer een andere key.${NC}"
        # Reset API_KEY so we ask again
        API_KEY=""
    fi
done

# Schrijf de nieuwe config met uitgebreide instellingen
cat > "$CONFIG_FILE" <<EOF
# -----------------------------------------------------------------------------
# SAFETY CONFIGURATION
# Use 'whitelist_patterns' to match the internal key seen in /config
# -----------------------------------------------------------------------------

whitelist_patterns:
# Navigation & File Listing
  - "^ls($| .*)"             # List files
  - "^ll($| .*)"
  - "^pwd$"                  # Print working directory
  - "^cd($| .*)"             # Change directory (safe navigation)
  - "^cat($| .*)"            # Read file content
  - "^find .* -type f.*"     # Find files (read-only check)

  # System Status & Info
  - "^date$"                 # Check date
  - "^whoami$"               # Check user
  - "^uptime$"               # Check system uptime
  - "^free($| .*)"           # Check memory
  - "^df($| .*)"             # Check disk space
  - "^du($| .*)"             # Check disk usage
  - "^top($| .*)"            # Process monitor (interactive but safe to start)
  - "^htop($| .*)"           # Process monitor

  # Git (Read-only operations)
  - "^git status.*"
  - "^git log.*"
  - "^git diff.*"
  - "^git show.*"
  - "^git branch$"
  - "^git remote -v"

  # Networking (Info only)
  - "^ping -c [0-9]+ .*"     # Ping (safe if count is limited)
  - "^curl -I .*"            # Curl headers only
  - "^ip addr.*"             # Check IP addresses
  - "^ifconfig.*"

  # Text Processing (Safe filters)
  - "^grep .*"
  - "^echo .*"
blacklist_patterns:
  # Destructive File Operations
  - "^rm .*"                 # Remove files
  - "^rm -rf .*"             # Force recursive remove (DANGER)
  - "^dd .*"                 # Disk dump (can wipe drives)
  - "^mkfs.*"                # Format filesystem
  - "^shred .*"              # Secure delete

  # Permissions & Ownership
  - "^chmod .*"              # Change mode
  - "^chown .*"              # Change owner

  # System State
  - "^shutdown.*"
  - "^reboot.*"
  - "^init [0-6]"
  - "^kill .*"               # Killing processes
  - "^killall .*"
  # Dangerous Redirection
  - ".*> /dev/sd.*"          # Writing directly to a raw device
  - ":(){ :|:& };:"          # Fork bomb pattern

# -----------------------------------------------------------------------------
# MODEL CONFIGURATION
# -----------------------------------------------------------------------------
models:
  primary:
    provider: openrouter
    base_url: "https://api.mistral.ai/v1"
    api_key: "$API_KEY"
    model: "devstral-latest"

# -----------------------------------------------------------------------------
# GLOBAL SETTINGS
# -----------------------------------------------------------------------------
debug: false
exec_confirm: true

# -----------------------------------------------------------------------------
# PROMPT SETTINGS
# -----------------------------------------------------------------------------

prompts:
    # Your current strict rule for running commands
    base_system: >
      You are an intelligent terminal assistant.
      1. If the user asks for a specific action, output ONLY the shell command.
      2. If the user asks for an explanation or analysis, you may answer in text, but EVERY line of text must start with a `#` character (so it is valid shell syntax).
      3. Do not use markdown formatting like **bold** or `code blocks`.
    chat_assistant: "You are a technical terminal expert. When asked for explanations, be concise and direct. Do not use conversational filler like 'Hi' or 'Sure'. specificy tools or flags clearly."
    chat_assistant_prepared: "You are an intelligent CLI assistant. The user prompt contains context: 'user@host:cwd[exit_code]'. Use this to detect errors. If the last exit code was non-zero, prioritize debugging."
EOF

echo -e "${GREEN}✓ Nieuwe configuratie geschreven naar $CONFIG_FILE${NC}"

# --- STAP 4: Uitleg ---
echo ""
echo "============================================="
echo -e "${GREEN}Installatie Voltooid!${NC}"
echo "============================================="
echo "Je bent klaar om te beginnen."
echo ""
echo -e "🚀  ${BLUE}Starten:${NC} Typ simpelweg ${GREEN}tmuxai${NC}"
echo ""
echo "Dit start automatisch een Tmux-sessie met de AI al geladen."
echo "Je hoeft tmux niet eerst apart te starten."
echo ""
echo -e "${BLUE}Hoe TmuxAI te gebruiken:${NC}"
echo -e "1. Start een nieuwe sessie met: ${GREEN}tmuxai${NC}"
echo "2. Typ je vraag of opdracht in de terminal."
echo "3. TmuxAI zal je input zien en je helpen."
echo ""
echo -e "${BLUE}Voorbeelden:${NC}"
echo "- 'Hoe maak ik een nieuw Python-bestand?'"
echo "- 'Leg uit hoe deze code werkt.'"
echo "- 'Help me met het debuggen van dit script.'"
echo "- 'Hoe gebruik ik git om mijn wijzigingen te committen?'"
echo "- 'Schrijf een script dat alle .txt bestanden in een map telt.'"
echo ""
echo -e "${BLUE}Tips:${NC}"
echo "- TmuxAI ziet alles in je huidige tmux-venster."
echo "- Je kunt meerdere panes openen en TmuxAI ziet ze allemaal."
echo "- Gebruik duidelijke en specifieke vragen voor de beste resultaten."
echo "- TmuxAI kan je helpen met code, uitleg, debugging en meer."
echo ""
echo "Provider: Mistral"
echo "Model: devstral-latest"
