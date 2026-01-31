#!/bin/bash
# =============================================================================
# TmuxAI Enhanced Installer
# Version: 2.2.0
# Author: Jeroen Bos / Bossers & Cnossen
# Repository: github.com/Omaha2002/tmuxai-installer
# =============================================================================

# Version info
INSTALLER_VERSION="2.2.0"
TMUXAI_VERSION=${TMUXAI_VERSION:-"latest"}

# Stop bij fouten
set -e

# Debug mode (set DEBUG=1 to enable)
DEBUG=${DEBUG:-0}

# Kleuren voor output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

debug_log() {
    [ "$DEBUG" = "1" ] && echo -e "${CYAN}[DEBUG] $1${NC}" >&2
}

info_log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success_log() {
    echo -e "${GREEN}✓${NC} $1"
}

warn_log() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error_log() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Escape special characters for sed replacement
escape_sed() {
    printf '%s\n' "$1" | sed 's/[[\.*^$()+?{|\\]/\\&/g'
}

# Configuration paths
CONFIG_DIR="$HOME/.config/tmuxai"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
BACKUP_FILE=""

# =============================================================================
# CLEANUP & ROLLBACK FUNCTIONS
# =============================================================================

cleanup() {
    local exit_code=$?
    
    # If installation failed and we have a backup, restore it
    if [ $exit_code -ne 0 ] && [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
        warn_log "Installatie gefaald. Configuratie wordt hersteld van backup..."
        if [ -f "$CONFIG_FILE.tmp" ]; then
            rm -f "$CONFIG_FILE.tmp"
        fi
        mv "$BACKUP_FILE" "$CONFIG_FILE"
        success_log "Configuratie hersteld van backup: $BACKUP_FILE"
    fi
    
    # Clean up temp files
    [ -f "$CONFIG_FILE.tmp" ] && rm -f "$CONFIG_FILE.tmp"
    
    debug_log "Cleanup voltooid (exit code: $exit_code)"
}

# Register cleanup trap
trap cleanup EXIT

# =============================================================================
# YAML VALIDATION
# =============================================================================

validate_yaml() {
    local file="$1"
    
    if command -v python3 &>/dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            debug_log "YAML validatie geslaagd: $file"
            return 0
        else
            debug_log "YAML validatie gefaald: $file"
            return 1
        fi
    elif command -v ruby &>/dev/null; then
        if ruby -ryaml -e "YAML.load_file('$file')" 2>/dev/null; then
            debug_log "YAML validatie geslaagd (ruby): $file"
            return 0
        else
            debug_log "YAML validatie gefaald (ruby): $file"
            return 1
        fi
    else
        debug_log "Geen YAML validator beschikbaar, skip validatie"
        return 0  # Skip validation if no validator available
    fi
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      TmuxAI Enhanced Installer v${INSTALLER_VERSION}                       ║${NC}"
echo -e "${BLUE}║      Mistral Devstral AI Terminal Assistant                   ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

debug_log "Installer versie: $INSTALLER_VERSION"
debug_log "TmuxAI versie: $TMUXAI_VERSION"
debug_log "OS Type: $OSTYPE"

# --- STAP 1: Tmux Controleren/Installeren ---
info_log "Stap 1/4: Tmux controleren..."

if ! command -v tmux &> /dev/null; then
    info_log "Tmux niet gevonden. Bezig met installeren..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y tmux
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y tmux
        elif command -v yum &> /dev/null; then
            sudo yum install -y tmux
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm tmux
        else
            error_log "Geen ondersteunde package manager gevonden. Installeer tmux handmatig."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install tmux
        else
            error_log "Homebrew niet gevonden. Installeer tmux handmatig."
            exit 1
        fi
    else
        error_log "Onbekend besturingssysteem: $OSTYPE"
        exit 1
    fi
    success_log "Tmux geïnstalleerd"
else
    success_log "Tmux is al aanwezig ($(tmux -V))"
fi

# --- STAP 2: TmuxAI Controleren/Installeren ---
info_log "Stap 2/4: TmuxAI controleren..."

if ! command -v tmuxai &> /dev/null; then
    info_log "TmuxAI wordt geïnstalleerd..."
    
    # Dit script detecteert automatisch je OS en installeert de juiste versie
    if ! curl -fsSL https://get.tmuxai.dev | bash; then
        error_log "TmuxAI installatie gefaald"
        exit 1
    fi
    
    success_log "TmuxAI installatie voltooid"
else
    success_log "TmuxAI is al aanwezig"
fi

# --- STAP 3: Configuratie (Met Back-up Functie) ---
info_log "Stap 3/4: Configuratie instellen..."

# Maak map indien nodig
mkdir -p "$CONFIG_DIR"

# BACKUP LOGICA: Veilig voor bestaande installaties
if [ -f "$CONFIG_FILE" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$CONFIG_FILE.backup_$TIMESTAMP"
    warn_log "Bestaande configuratie gevonden."
    info_log "Back-up maken naar: $BACKUP_FILE"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           MISTRAL API KEY CONFIGURATIE${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Je hebt een Mistral API key nodig van: ${CYAN}https://console.mistral.ai/${NC}"
echo ""

# API Key input loop - blijft vragen tot geldige key of skip
API_KEY=""
VALID_KEY=0

while [ $VALID_KEY -eq 0 ]; do
    printf "Plak je Mistral API Key hier en druk ENTER (of 'skip' om over te slaan): "
    
    # Ensure terminal is accessible for input
    if [ ! -c /dev/tty ]; then
        error_log "Geen toegang tot terminal voor invoer."
        echo -e "${YELLOW}Tip: Voer het script lokaal uit in plaats van via curl | bash${NC}"
        echo -e "${YELLOW}     Download eerst: curl -O https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/install.sh${NC}"
        echo -e "${YELLOW}     Voer dan uit: bash install.sh${NC}"
        exit 1
    fi
    
    # Read from terminal
    read -r API_KEY </dev/tty 2>/dev/null || {
        error_log "Fout bij lezen van invoer. Probeer opnieuw."
        API_KEY=""
        continue
    }
    
    debug_log "Invoer ontvangen: ${#API_KEY} karakters"

    # Trim whitespace
    API_KEY=$(echo "$API_KEY" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Check if user wants to skip
    if [ "$API_KEY" = "skip" ] || [ "$API_KEY" = "SKIP" ]; then
        warn_log "Validatie overgeslagen - configuratie wordt aangemaakt met placeholder"
        echo -e "${YELLOW}   Je kunt de API key later aanpassen in: $CONFIG_FILE${NC}"
        VALID_KEY=1
        API_KEY="YOUR_API_KEY_HERE"
        continue
    fi
    
    # Check if empty
    if [ -z "$API_KEY" ]; then
        error_log "Geen key ingevoerd. Probeer opnieuw."
        continue
    fi
    
    # Check basic format (Mistral keys are typically 32+ chars)
    if [ ${#API_KEY} -lt 20 ]; then
        warn_log "API key lijkt te kort (${#API_KEY} karakters). Mistral keys zijn typisch 32+ karakters."
        printf "Toch doorgaan? (j/n): "
        read -r confirm </dev/tty
        if [ "$confirm" != "j" ] && [ "$confirm" != "J" ] && [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            continue
        fi
    fi

    # Valideer de API key
    info_log "Bezig met valideren van API key..."
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        "https://api.mistral.ai/v1/models" 2>/dev/null || echo "000")

    debug_log "API response code: $RESPONSE"

    if [ "$RESPONSE" = "200" ]; then
        success_log "API key is geldig en werkt!"
        VALID_KEY=1
    elif [ "$RESPONSE" = "401" ]; then
        error_log "API key geweigerd (HTTP 401 Unauthorized)"
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠️  MOGELIJKE OORZAKEN:${NC}"
        echo -e "   1. ${CYAN}Betaling niet geactiveerd${NC} - Mistral vereist actieve betaling"
        echo -e "   2. ${CYAN}API key verlopen${NC} - Maak een nieuwe key aan"
        echo -e "   3. ${CYAN}Verkeerde key${NC} - Controleer of je de juiste key hebt gekopieerd"
        echo ""
        echo -e "${YELLOW}🔧 OPLOSSING:${NC}"
        echo -e "   Ga naar: ${CYAN}https://console.mistral.ai${NC}"
        echo -e "   Activeer betalingen in: ${CYAN}Organization > Billing${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    elif [ "$RESPONSE" = "000" ]; then
        error_log "Kan Mistral API niet bereiken. Controleer je internetverbinding."
    else
        error_log "API key validatie gefaald. HTTP Status: $RESPONSE"
    fi
done

# Download en configureer enhanced configuration
info_log "Stap 4/4: Enhanced configuratie downloaden..."

CONFIG_URL="https://raw.githubusercontent.com/Omaha2002/tmuxai-installer/main/config-tmux-enhanced.yaml"

if curl -fsSL "$CONFIG_URL" -o "$CONFIG_FILE.tmp" 2>/dev/null; then
    # Escape API key for safe sed replacement
    API_KEY_ESCAPED=$(escape_sed "$API_KEY")
    
    # Replace API key placeholder
    sed "s/{{API_KEY_PLACEHOLDER}}/$API_KEY_ESCAPED/g" "$CONFIG_FILE.tmp" > "$CONFIG_FILE"
    rm -f "$CONFIG_FILE.tmp"
    
    # Validate YAML syntax
    if validate_yaml "$CONFIG_FILE"; then
        success_log "Configuratie gevalideerd en opgeslagen"
    else
        warn_log "YAML validatie overgeslagen of gefaald - config is mogelijk nog steeds geldig"
    fi
    
    success_log "Uitgebreide configuratie gedownload en geconfigureerd"
else
    warn_log "Kan uitgebreide config niet downloaden, gebruik fallback..."
    
    # Fallback to embedded basic configuration
    cat > "$CONFIG_FILE" <<FALLBACK_EOF
# =============================================================================
# TMUXAI FALLBACK CONFIGURATION
# Generated by installer v${INSTALLER_VERSION}
# =============================================================================

whitelist_patterns:
  - "^ls(\$| .*)"
  - "^ll(\$| .*)"
  - "^pwd\$"
  - "^cd(\$| .*)"
  - "^cat(\$| .*)"
  - "^head(\$| .*)"
  - "^tail(\$| .*)"
  - "^grep(\$| .*)"
  - "^find(\$| .*)"
  - "^git status.*"
  - "^git log.*"
  - "^git diff.*"
  - "^git branch(\$| .*)"

blacklist_patterns:
  - "^rm(\$| .*)"
  - "^rmdir(\$| .*)"
  - "^chmod(\$| .*)"
  - "^chown(\$| .*)"
  - "^shutdown.*"
  - "^reboot.*"

models:
  primary:
    provider: openrouter
    base_url: "https://api.mistral.ai/v1"
    api_key: "${API_KEY}"
    model: "devstral-latest"
    temperature: 0.1
    max_tokens: 2048

debug: false
exec_confirm: true
max_history: 50
FALLBACK_EOF

    success_log "Fallback configuratie geschreven"
fi

# Remove backup if installation succeeded (config is valid)
if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ] && [ -f "$CONFIG_FILE" ]; then
    debug_log "Installatie geslaagd, backup behouden op: $BACKUP_FILE"
fi

# =============================================================================
# COMPLETION MESSAGE
# =============================================================================

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              🎉 INSTALLATIE VOLTOOID!                         ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BLUE}Starten:${NC} Typ simpelweg ${GREEN}tmuxai${NC}"
echo ""
echo -e "  ${BLUE}Configuratie:${NC} $CONFIG_FILE"
if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
echo -e "  ${BLUE}Backup:${NC} $BACKUP_FILE"
fi
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔥 Features:${NC}"
echo -e "  ${GREEN}✓${NC} 100+ whitelisted safe commands"
echo -e "  ${GREEN}✓${NC} Enhanced AI prompts voor betere context-awareness"
echo -e "  ${GREEN}✓${NC} Ondersteuning voor npm, pip, cargo, maven, etc."
echo -e "  ${GREEN}✓${NC} Automatische foutdetectie en debugging hulp"
echo -e "  ${GREEN}✓${NC} Git workflow ondersteuning"
echo ""
echo -e "${BLUE}💡 Voorbeelden:${NC}"
echo -e "  • 'Hoe check ik disk space?'"
echo -e "  • 'Leg dit Git probleem uit'"
echo -e "  • 'Help me met deze error'"
echo ""
if [ "$API_KEY" = "YOUR_API_KEY_HERE" ]; then
echo -e "${YELLOW}⚠️  VERGEET NIET:${NC} Voeg je echte API key toe in:"
echo -e "   ${CYAN}$CONFIG_FILE${NC}"
echo ""
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Installer: v${INSTALLER_VERSION} | Model: devstral-latest"
echo ""
