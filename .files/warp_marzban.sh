#!/bin/bash

#================================================================================
#      Marzban Warp Installer & Configurator by PeDitX
# This script automates the installation of Cloudflare Warp using the
# kernel WireGuard module and provides the necessary JSON snippets for Marzban.
# It is designed to be safe and will exit immediately if any step fails.
#================================================================================

# --- Set script to exit on any error ---
set -e

# --- Colors for better readability ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'

# --- Function to print error messages and exit ---
error_exit() {
    echo -e "\n${C_RED}Error: $1${C_RESET}\n" >&2
    exit 1
}

# --- Check for root privileges ---
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run as root. Please use 'sudo'."
fi

# --- Welcome Message ---
echo -e "${C_GREEN}=====================================================${C_RESET}"
echo -e "${C_YELLOW}  Marzban Warp Installer & Configurator by PeDitX  ${C_RESET}"
echo -e "${C_GREEN}=====================================================${C_RESET}"
echo -e "\nThis script will automate the installation of Cloudflare Warp for your Marzban panel."
echo -e "It is designed to be safe and will stop if any command fails."
echo -e "\n${C_BLUE}The only information you might need is an optional Warp+ license key.${C_RESET}"
read -p "Press Enter to continue..."

# --- Step 1: Install prerequisites ---
echo -e "\n${C_BLUE}Step 1: Installing prerequisites...${C_RESET}"
if command -v apt-get &> /dev/null; then
    apt-get update -y >/dev/null
    apt-get install wireguard-tools resolvconf curl jq -y >/dev/null || error_exit "Failed to install prerequisites on Debian/Ubuntu."
elif command -v yum &> /dev/null; then
    yum install epel-release -y >/dev/null
    yum install wireguard-tools curl jq -y >/dev/null || error_exit "Failed to install prerequisites on CentOS/RHEL."
else
    error_exit "Unsupported package manager. Please use Debian/Ubuntu or CentOS/RHEL."
fi
echo -e "${C_GREEN}Prerequisites installed successfully.${C_RESET}"

# --- Step 2: Install wgcf ---
echo -e "\n${C_BLUE}Step 2: Installing wgcf (Warp config generator)...${C_RESET}"
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    WGCF_URL="https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_amd64"
elif [ "$ARCH" == "aarch64" ] || [ "$ARCH" == "arm64" ]; then
    WGCF_URL="https://github.com/ViRb3/wgcf/releases/download/v2.2.22/wgcf_2.2.22_linux_arm64"
else
    error_exit "Unsupported architecture: $ARCH"
fi

curl -fsSL "$WGCF_URL" -o /usr/local/bin/wgcf
chmod +x /usr/local/bin/wgcf
echo -e "${C_GREEN}wgcf installed successfully.${C_RESET}"

# --- Step 3: Generate Warp config ---
echo -e "\n${C_BLUE}Step 3: Generating Warp configuration...${C_RESET}"
cd /tmp
rm -f wgcf-account.toml wgcf-profile.conf

wgcf register --accept-tos >/dev/null
wgcf generate >/dev/null

# --- Optional Warp+ ---
read -p "Do you have a Warp+ license key to use? (y/N): " use_warp_plus
if [[ "$use_warp_plus" =~ ^[Yy]$ ]]; then
    read -p "Please enter your Warp+ license key: " warp_plus_key
    if [ -n "$warp_plus_key" ]; then
        sed -i "s/license_key = .*/license_key = \"$warp_plus_key\"/" wgcf-account.toml
        echo "Updating to Warp+..."
        wgcf update --name "WarpPlus" >/dev/null || echo -e "${C_YELLOW}Warning: Could not update account name, but proceeding.${C_RESET}"
        wgcf generate >/dev/null
        echo -e "${C_GREEN}Warp+ profile generated.${C_RESET}"
    fi
fi

# --- Step 4: Secure and move config ---
echo -e "\n${C_BLUE}Step 4: Securing and moving the configuration...${C_RESET}"
if ! grep -q "\[Interface\]" wgcf-profile.conf; then
    error_exit "Generated profile is invalid."
fi
sed -i '/\[Interface\]/a Table = off' wgcf-profile.conf
mkdir -p /etc/wireguard
mv wgcf-profile.conf /etc/wireguard/warp.conf
echo -e "${C_GREEN}Configuration secured and moved successfully.${C_RESET}"

# --- Step 5: Activate service ---
echo -e "\n${C_BLUE}Step 5: Activating Warp service...${C_RESET}"
systemctl enable --now wg-quick@warp >/dev/null 2>&1

sleep 5
if ! systemctl is-active --quiet wg-quick@warp; then
    echo -e "${C_RED}Warp service failed to start. Showing logs:${C_RESET}"
    journalctl -u wg-quick@warp --no-pager -n 50
    error_exit "Aborting due to service failure."
fi
echo -e "${C_GREEN}Warp service is active and enabled on boot.${C_RESET}"

# --- Step 6: Verify connection ---
echo -e "\n${C_BLUE}Step 6: Verifying outbound connection via Warp...${C_RESET}"
WARP_IP=$(curl -s --interface warp https://www.cloudflare.com/cdn-cgi/trace | grep ip= | cut -d= -f2)
if [[ -n "$WARP_IP" ]]; then
    echo -e "${C_GREEN}Success! Your new outbound IP via Warp is: $WARP_IP${C_RESET}"
else
    echo -e "${C_YELLOW}Warning: Could not verify IP via Warp, but the service is running. Check your firewall if issues persist.${C_RESET}"
fi

# --- Step 7: Final instructions ---
echo -e "\n${C_GREEN}==========================================================${C_RESET}"
echo -e "${C_YELLOW}         Marzban Panel Configuration (Final Step)         ${C_RESET}"
echo -e "${C_GREEN}==========================================================${C_RESET}"

echo -e "\n${C_YELLOW}1. Add this JSON object to your 'outbounds' array in 'Core Settings':${C_RESET}"
cat << EOF

${C_GREEN}
{
  "tag": "WARP-Out",
  "protocol": "freedom",
  "settings": {
    "domainStrategy": "UseIP"
  },
  "streamSettings": {
    "sockopt": {
      "interface": "warp"
    }
  }
}
${C_RESET}
EOF

echo -e "\n${C_YELLOW}2. (Optional) To route specific domains, add this 'rule' to 'routing':${C_RESET}"
cat << EOF

${C_GREEN}
{
  "outboundTag": "WARP-Out",
  "domain": [
    "geosite:google",
    "geosite:openai",
    "geosite:spotify",
    "geosite:netflix",
    "ipinfo.io"
  ],
  "type": "field"
}
${C_RESET}
EOF

echo -e "\nTo disable Warp, run: ${C_YELLOW}sudo systemctl disable --now wg-quick@warp${C_RESET}"
echo -e "\n${C_GREEN}Installation finished successfully!${C_RESET}"
rm -f wgcf-account.toml


