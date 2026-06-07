#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#   Termux Auto Setup Script
#   Installs essential packages, Python libs, aliases & more
#   github.com/taisizlar/termux-setup
# ============================================================

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
RESET='\033[0m'

# ── State tracking ──────────────────────────────────────────
FAILED=()
SUCCESS=()
SKIPPED=()
TOTAL=0
CURRENT=0

# ── tput fallback — some Termux builds glitch with cuu1 ─────
clear_prev_lines() {
    local n="${1:-1}"
    if tput cuu1 &>/dev/null; then
        for ((i=0; i<n; i++)); do tput cuu1; tput el; done
    else
        # fallback: just print a blank line separator
        echo ""
    fi
}

# ── Helpers ─────────────────────────────────────────────────
print_banner() {
    clear
    echo -e "${CYAN}${BOLD}  🚀 Termux Auto Setup${RESET}  ${BLUE}by taisizlar${RESET}"
    echo -e "${BLUE}  ──────────────────────────────────────────────────${RESET}\n"
}

log_info()    { echo -e "  ${CYAN}[INFO]${RESET}  $1"; }
log_ok()      { echo -e "  ${GREEN}[✔]${RESET}    $1"; }
log_skip()    { echo -e "  ${BLUE}[~]${RESET}    $1 (already installed)"; }
log_warn()    { echo -e "  ${YELLOW}[⚠]${RESET}    $1"; }
log_error()   { echo -e "  ${RED}[✘]${RESET}    $1"; }
log_section() { echo -e "\n${BOLD}${BLUE}▸ $1${RESET}\n"; }

# Renders a progress bar based on CURRENT / TOTAL
progress_bar() {
    local percent=$(( CURRENT * 100 / TOTAL ))
    local filled=$(( percent / 5 ))
    local empty=$(( 20 - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done
    printf "  ${CYAN}[${bar}]${RESET} ${BOLD}%3d%%${RESET}  (%d/%d)\n" "$percent" "$CURRENT" "$TOTAL"
}

# ── Internet check ───────────────────────────────────────────
check_internet() {
    log_section "Checking Internet Connection"
    if curl -s --max-time 5 https://google.com -o /dev/null; then
        log_ok "Internet is available."
    else
        log_error "No internet connection! Please check your network and try again."
        exit 1
    fi
}

# ── System update ────────────────────────────────────────────
update_system() {
    log_section "Updating & Upgrading Packages"
    log_info "Running pkg update & upgrade..."
    if pkg update -y &>/dev/null && pkg upgrade -y &>/dev/null; then
        log_ok "System updated successfully."
    else
        log_warn "Update encountered issues — continuing anyway..."
    fi
}

# ── pkg install — skips if already installed ─────────────────
install_pkg() {
    local pkg="$1"
    CURRENT=$(( CURRENT + 1 ))

    # Skip if already installed
    if pkg list-installed 2>/dev/null | grep -q "^${pkg}/"; then
        log_skip "$pkg"
        SKIPPED+=("$pkg")
        return
    fi

    printf "  ${YELLOW}◉ Installing:${RESET} %-25s" "$pkg"
    progress_bar

    if pkg install -y "$pkg" &>/dev/null; then
        clear_prev_lines 2
        log_ok "$pkg"
        SUCCESS+=("$pkg")
    else
        clear_prev_lines 2
        log_error "$pkg — installation failed"
        FAILED+=("$pkg")
    fi
}

# ── pip install — checks pip exists, skips if installed ──────
install_pip() {
    local pkg="$1"

    # Check pip is available
    if ! command -v pip &>/dev/null; then
        log_error "pip not found — skipping Python packages."
        FAILED+=("pip:$pkg")
        return
    fi

    # Skip if already installed (pip show exit 0 = installed)
    if pip show "$pkg" &>/dev/null; then
        log_skip "pip:$pkg"
        SKIPPED+=("pip:$pkg")
        return
    fi

    printf "  ${YELLOW}◉ pip install:${RESET} %-20s\n" "$pkg"
    if pip install --upgrade "$pkg" -q --no-warn-script-location 2>/dev/null; then
        clear_prev_lines 1
        log_ok "$pkg"
        SUCCESS+=("pip:$pkg")
    else
        clear_prev_lines 1
        log_error "$pkg — pip install failed"
        FAILED+=("pip:$pkg")
    fi
}

# ── gem install — checks gem exists, skips if installed ──────
install_gem() {
    local pkg="$1"

    # Check gem is available
    if ! command -v gem &>/dev/null; then
        log_error "gem not found — skipping Ruby gems."
        FAILED+=("gem:$pkg")
        return
    fi

    # Skip if already installed
    if gem list "$pkg" 2>/dev/null | grep -q "^${pkg}"; then
        log_skip "gem:$pkg"
        SKIPPED+=("gem:$pkg")
        return
    fi

    log_info "Installing $pkg..."
    if gem install "$pkg" &>/dev/null; then
        clear_prev_lines 1
        log_ok "$pkg"
        SUCCESS+=("gem:$pkg")
    else
        clear_prev_lines 1
        log_error "$pkg — gem install failed"
        FAILED+=("gem:$pkg")
    fi
}

# ── Aliases setup ────────────────────────────────────────────
setup_aliases() {
    log_section "Setting Up Aliases in ~/.bashrc"

    local BASHRC="$HOME/.bashrc"
    local MARKER="# ── Termux Setup Aliases ──"

    # Skip if aliases were already added
    if grep -q "$MARKER" "$BASHRC" 2>/dev/null; then
        log_warn "Aliases already exist in ~/.bashrc — skipped."
        return
    fi

    cat >> "$BASHRC" <<'EOF'

# ── Termux Setup Aliases ──
alias cls='clear'
alias py='python'
alias update='pkg update && pkg upgrade'
alias serve='python -m http.server 8000'
# ─────────────────────────
EOF

    log_ok "alias cls='clear'"
    log_ok "alias py='python'"
    log_ok "alias update='pkg update && pkg upgrade'"
    log_ok "alias serve='python -m http.server 8000'"
}

# ── Final summary ────────────────────────────────────────────
print_summary() {
    echo -e "\n${BLUE}  ──────────────────────────────────────────────────${RESET}"
    echo -e "${BOLD}  📋 Installation Summary${RESET}\n"

    echo -e "  ${GREEN}✔ Installed : ${#SUCCESS[@]} packages${RESET}"
    echo -e "  ${BLUE}~ Skipped   : ${#SKIPPED[@]} packages (already present)${RESET}"

    if [ ${#FAILED[@]} -gt 0 ]; then
        echo -e "  ${RED}✘ Failed    : ${#FAILED[@]} packages${RESET}"
        echo -e "\n  ${RED}Failed packages:${RESET}"
        for pkg in "${FAILED[@]}"; do
            echo -e "    ${RED}• $pkg${RESET}"
        done
        echo -e "\n  ${YELLOW}[TIP]${RESET} To install manually: ${CYAN}pkg install <package-name>${RESET}"
    else
        echo -e "\n  ${GREEN}${BOLD}🎉 All packages installed successfully!${RESET}"
    fi

    echo -e "${BLUE}\n  ──────────────────────────────────────────────────${RESET}"
    echo -e "  ${MAGENTA}${BOLD}✅ Your Termux is ready to go! 😎${RESET}\n"
}

# ════════════════════════════════════════════════════════════
#   Main
# ════════════════════════════════════════════════════════════

print_banner
check_internet
update_system

# ── Package lists ────────────────────────────────────────────
PKG_ESSENTIALS=(git wget zip unzip tar vim nano)
PKG_DEV=(python python2 clang nodejs ruby php)
PKG_TOOLS=(openssh curl proot dnsutils htop nmap termux-api termux-tools)
PKG_FUN=(cmatrix cowsay figlet toilet tor)

ALL_PKGS=("${PKG_ESSENTIALS[@]}" "${PKG_DEV[@]}" "${PKG_TOOLS[@]}" "${PKG_FUN[@]}")
TOTAL=${#ALL_PKGS[@]}

# ── Install pkg packages by category ────────────────────────
log_section "Essential Tools"
for pkg in "${PKG_ESSENTIALS[@]}"; do install_pkg "$pkg"; done

log_section "Development Environment"
for pkg in "${PKG_DEV[@]}"; do install_pkg "$pkg"; done

log_section "Network & System Tools"
for pkg in "${PKG_TOOLS[@]}"; do install_pkg "$pkg"; done

log_section "Fun Tools"
for pkg in "${PKG_FUN[@]}"; do install_pkg "$pkg"; done

# ── Install Ruby gems ────────────────────────────────────────
log_section "Ruby Gems"
install_gem lolcat

# ── Install Python packages via pip ─────────────────────────
log_section "Python Packages (pip)"
PIP_PKGS=(colorama Flask mnemonic python-dotenv requests setuptools Telethon wheel)
for pkg in "${PIP_PKGS[@]}"; do install_pip "$pkg"; done

# ── Configure aliases ────────────────────────────────────────
setup_aliases

# ── Suppress login messages ──────────────────────────────────
log_section "Appearance"
if touch ~/.hushlogin 2>/dev/null; then
    log_ok "~/.hushlogin created — login messages suppressed."
else
    log_warn "Could not create ~/.hushlogin."
fi

# ── Request storage permission ───────────────────────────────
log_section "Storage Permission"
log_info "Requesting storage access..."
log_warn "A permission dialog will appear — please tap Allow."
termux-setup-storage
log_ok "Storage permission request sent."

# ── Print summary ────────────────────────────────────────────
print_summary

# ── Apply bashrc changes immediately ─────────────────────────
log_info "Applying ~/.bashrc changes..."
# shellcheck source=/dev/null
source "$HOME/.bashrc" 2>/dev/null \
    && log_ok "Aliases are now active." \
    || log_warn "Could not source ~/.bashrc — please restart Termux."

echo -e ""
