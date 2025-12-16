#!/bin/sh

# PeDitXOS Service Runner v3
# This script contains the installation and uninstallation logic for Store applications.

ACTION="$1"

# --- Dynamic URLs Start ---
URL_INSTALL_INSTALLDNSJUMPER="https://peditx.ir/projects/DNSJumper/code/install.sh"
URL_INSTALL_PXNOTIFIER="https://peditx.ir/projects/PXnotifier/code/install.sh"
URL_INSTALL_INSTALLAIRCAST="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_install.sh"
URL_INSTALL_ADGUARDHOME="https://peditx.ir/projects/AdGuard-Home/install.sh"
URL_INSTALL_NETDATA="https://peditx.ir/projects/NetData/install.sh"
URL_INSTALL_NEXTCLOUD="https://peditx.ir/projects/NextCloud/install.sh"
URL_INSTALL_PLEXMEDIASERVER="https://peditx.ir/projects/PlexServer/install.sh"
URL_INSTALL_HOMEASSISTANT="https://peditx.ir/projects/Home%20Assistant-x86-pi/install.sh"
URL_INSTALL_HOMEBRIDGE="https://peditx.ir/projects/HomeBridge/install.sh"
URL_INSTALL_MOSQUITTOMQTT="https://peditx.ir/projects/Mosquitto/install.sh"
URL_INSTALL_NODERED="https://peditx.ir/projects/Node-Red/install.sh"
URL_INSTALL_PORTAINER="https://peditx.ir/projects/Portainer-x86-pi/install.sh"
URL_INSTALL_DOCKER="https://peditx.ir/projects/docker/install.sh"
URL_INSTALL_WIREGUARDPLUS="https://peditx.ir/projects/WireGuard-Plus/install.sh"
URL_INSTALL_L2TPPLUS="https://peditx.ir/projects/L2tp-Plus/install.sh"
URL_INSTALL_SSTPPLUS="https://peditx.ir/projects/SStp-Plus/install.sh"
URL_INSTALL_IKEV2PLUS="https://peditx.ir/projects/IKEv2-Plus/install.sh"
URL_INSTALL_OPENVPNPLUS="https://peditx.ir/projects/OpenVPN_Plus/install.sh"
URL_INSTALL_INSTALLTORPLUS="https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/install.sh"
URL_INSTALL_INSTALLSSHPLUS="https://raw.githubusercontent.com/peditx/SshPlus/main/Files/install_sshplus.sh"
URL_INSTALL_WARP="https://raw.githubusercontent.com/peditx/openwrt-warpplus/refs/heads/main/files/install.sh"
URL_INSTALL_WARPPLUSPLUS="https://raw.githubusercontent.com/peditx/openwrt-warpplusplus/refs/heads/main/install.sh"
URL_INSTALL_OPENCLASHPLUS="https://peditx.ir/foreignscs/OpenClash/install.sh"
URL_INSTALL_AMNEZIAWG="https://raw.githubusercontent.com/Slava-Shchipunov/awg-openwrt/refs/heads/master/amneziawg-install.sh"
URL_INSTALL_IRANIPS="https://raw.githubusercontent.com/peditx/iranIPS/refs/heads/main/.files/iranips.sh"
URL_INSTALL_LINUXTINYDESKTOP="https://peditx.ir/projects/Linux/install.sh"
URL_INSTALL_CARBONPX="https://raw.githubusercontent.com/peditx/luci-theme-carbonpx/refs/heads/main/install.sh"
URL_INSTALL_PEDITX="https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/install.sh"
URL_INSTALL_INSTALLAURORATHEME="https://peditx.ir/foreignscs/luci-theme-aurora/install.sh"
URL_INSTALL_INSTALLARGONTHEME="https://peditx.ir/foreignscs/luci-theme-argon/install.sh"
# --- Dynamic URLs End ---

# --- Dynamic Uninstall URLs Start ---
URL_UNINSTALL_INSTALLDNSJUMPER="https://peditx.ir/projects/DNSJumper/code/uninstall.sh"
URL_UNINSTALL_PXNOTIFIER="https://peditx.ir/projects/PXnotifier/code/uninstall.sh"
URL_UNINSTALL_INSTALLAIRCAST="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_uninstall.sh"
URL_UNINSTALL_ADGUARDHOME="https://peditx.ir/projects/AdGuard-Home/uninstall.sh"
URL_UNINSTALL_NETDATA="https://peditx.ir/projects/NetData/uninstall.sh"
URL_UNINSTALL_NEXTCLOUD="https://peditx.ir/projects/NextCloud/uninstall.sh"
URL_UNINSTALL_PLEXMEDIASERVER="https://peditx.ir/projects/PlexServer/uninstall.sh"
URL_UNINSTALL_HOMEASSISTANT="https://peditx.ir/projects/Home%20Assistant-x86-pi/uninstall.sh"
URL_UNINSTALL_HOMEBRIDGE="https://peditx.ir/projects/HomeBridge/uninstall.sh"
URL_UNINSTALL_MOSQUITTOMQTT="https://peditx.ir/projects/Mosquitto/uninstall.sh"
URL_UNINSTALL_NODERED="https://peditx.ir/projects/Node-Red/uninstall.sh"
URL_UNINSTALL_PORTAINER="https://peditx.ir/projects/Portainer-x86-pi/uninstall.sh"
URL_UNINSTALL_DOCKER="https://peditx.ir/projects/docker/uninstall.sh"
URL_UNINSTALL_WIREGUARDPLUS="https://peditx.ir/projects/WireGuard-Plus/uninstall.sh"
URL_UNINSTALL_L2TPPLUS="https://peditx.ir/projects/L2tp-Plus/uninstall.sh"
URL_UNINSTALL_SSTPPLUS="https://peditx.ir/projects/SStp-Plus/uninstall.sh"
URL_UNINSTALL_IKEV2PLUS="https://peditx.ir/projects/IKEv2-Plus/uninstall.sh"
URL_UNINSTALL_OPENVPNPLUS="https://peditx.ir/projects/OpenVPN_Plus/uninstall.sh"
URL_UNINSTALL_INSTALLTORPLUS="https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/uninstall.sh"
URL_UNINSTALL_INSTALLSSHPLUS="https://raw.githubusercontent.com/peditx/SshPlus/main/Files/uninstall_sshplus.sh"
URL_UNINSTALL_WARP="https://raw.githubusercontent.com/peditx/openwrt-warpplus/refs/heads/main/files/uninstall.sh"
URL_UNINSTALL_WARPPLUSPLUS="https://raw.githubusercontent.com/peditx/openwrt-warpplusplus/refs/heads/main/uninstall.sh"
URL_UNINSTALL_OPENCLASHPLUS="https://peditx.ir/foreignscs/OpenClash/uninstall.sh"
URL_UNINSTALL_LINUXTINYDESKTOP="https://peditx.ir/projects/Linux/uninstall.sh"
URL_UNINSTALL_INSTALLAURORATHEME="https://peditx.ir/foreignscs/luci-theme-aurora/uninstall.sh"
URL_UNINSTALL_INSTALLARGONTHEME="https://peditx.ir/foreignscs/luci-theme-argon/uninstall.sh"
# --- Dynamic Uninstall URLs End ---


# --- Dynamic Functions Start ---
install_installdnsjumper() {
	echo "Downloading DNSJumper components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLDNSJUMPER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_pxnotifier() {
	echo "Downloading PXNotifier components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_PXNOTIFIER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installaircast() {
	echo "Downloading Air-Cast components..."
	cd /tmp && rm -f aircast_install.sh && wget -q "$URL_INSTALL_INSTALLAIRCAST" -O aircast_install.sh && chmod +x aircast_install.sh && sh aircast_install.sh
}

install_adguardhome() {
	echo "Downloading AdGuard Home components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_ADGUARDHOME" -O install.sh && chmod +x install.sh && sh install.sh
}

install_netdata() {
	echo "Downloading NetData components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_NETDATA" -O install.sh && chmod +x install.sh && sh install.sh
}

install_nextcloud() {
	echo "Downloading NextCloud components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_NEXTCLOUD" -O install.sh && chmod +x install.sh && sh install.sh
}

install_plexmediaserver() {
	echo "Downloading Plex Media Server components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_PLEXMEDIASERVER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_homeassistant() {
	echo "Downloading Home Assistant components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_HOMEASSISTANT" -O install.sh && chmod +x install.sh && sh install.sh
}

install_homebridge() {
	echo "Downloading Home Bridge components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_HOMEBRIDGE" -O install.sh && chmod +x install.sh && sh install.sh
}

install_mosquittomqtt() {
	echo "Downloading Mosquitto mqtt components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_MOSQUITTOMQTT" -O install.sh && chmod +x install.sh && sh install.sh
}

install_nodered() {
	echo "Downloading Node-Red components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_NODERED" -O install.sh && chmod +x install.sh && sh install.sh
}

install_portainer() {
	echo "Downloading Portainer  components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_PORTAINER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_docker() {
	echo "Downloading Docker components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_DOCKER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_wireguardplus() {
	echo "Downloading WireGuard Plus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_WIREGUARDPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_l2tpplus() {
	echo "Downloading L2tp Plus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_L2TPPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_sstpplus() {
	echo "Downloading SStp Plus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_SSTPPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_ikev2plus() {
	echo "Downloading IKEv2 Plus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_IKEV2PLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_openvpnplus() {
	echo "Downloading OpenVPN Plus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_OPENVPNPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installtorplus() {
	echo "Downloading TORPlus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLTORPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installsshplus() {
	echo "Downloading SSHPlus components..."
	cd /tmp && rm -f install_sshplus.sh && wget -q "$URL_INSTALL_INSTALLSSHPLUS" -O install_sshplus.sh && chmod +x install_sshplus.sh && sh install_sshplus.sh
}

install_warp() {
	echo "Downloading Warp+ components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_WARP" -O install.sh && chmod +x install.sh && sh install.sh
}

install_warpplusplus() {
	echo "Downloading Warp++ components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_WARPPLUSPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_openclashplus() {
	echo "Downloading OpenClash Plus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_OPENCLASHPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_amneziawg() {
	echo "Downloading AmneziaWG components..."
	cd /tmp && rm -f amneziawg-install.sh && wget -q "$URL_INSTALL_AMNEZIAWG" -O amneziawg-install.sh && chmod +x amneziawg-install.sh && sh amneziawg-install.sh
}

install_iranips() {
	echo "Downloading Iran Rule IPS for Passwall2 components..."
	cd /tmp && rm -f iranips.sh && wget -q "$URL_INSTALL_IRANIPS" -O iranips.sh && chmod +x iranips.sh && sh iranips.sh
}

install_linuxtinydesktop() {
	echo "Downloading Linux Tiny Desktop components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_LINUXTINYDESKTOP" -O install.sh && chmod +x install.sh && sh install.sh
}

install_carbonpx() {
	echo "Downloading CarbonPX Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_CARBONPX" -O install.sh && chmod +x install.sh && sh install.sh
}

install_peditx() {
	echo "Downloading PeDitX Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_PEDITX" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installauroratheme() {
	echo "Downloading Aurora Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLAURORATHEME" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installargontheme() {
	echo "Downloading Argon Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLARGONTHEME" -O install.sh && chmod +x install.sh && sh install.sh
}
# --- Dynamic Functions End ---

# --- Dynamic Uninstall Functions Start ---
uninstall_installdnsjumper() {
	echo "Downloading Uninstall DNSJumper components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_INSTALLDNSJUMPER" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_pxnotifier() {
	echo "Downloading Uninstall PXNotifier components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_PXNOTIFIER" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_installaircast() {
	echo "Downloading Uninstall Air-Cast components..."
	cd /tmp && rm -f aircast_uninstall.sh && wget -q "$URL_UNINSTALL_INSTALLAIRCAST" -O aircast_uninstall.sh && chmod +x aircast_uninstall.sh && sh aircast_uninstall.sh
}

uninstall_adguardhome() {
	echo "Downloading Uninstall AdGuard Home components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_ADGUARDHOME" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_netdata() {
	echo "Downloading Uninstall NetData components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_NETDATA" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_nextcloud() {
	echo "Downloading Uninstall NextCloud components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_NEXTCLOUD" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_plexmediaserver() {
	echo "Downloading Uninstall Plex Media Server components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_PLEXMEDIASERVER" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_homeassistant() {
	echo "Downloading Uninstall Home Assistant components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_HOMEASSISTANT" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_homebridge() {
	echo "Downloading Uninstall Home Bridge components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_HOMEBRIDGE" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_mosquittomqtt() {
	echo "Downloading Uninstall Mosquitto mqtt components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_MOSQUITTOMQTT" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_nodered() {
	echo "Downloading Uninstall Node-Red components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_NODERED" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_portainer() {
	echo "Downloading Uninstall Portainer  components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_PORTAINER" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_docker() {
	echo "Downloading Uninstall Docker components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_DOCKER" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_wireguardplus() {
	echo "Downloading Uninstall WireGuard Plus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_WIREGUARDPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_l2tpplus() {
	echo "Downloading Uninstall L2tp Plus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_L2TPPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_sstpplus() {
	echo "Downloading Uninstall SStp Plus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_SSTPPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_ikev2plus() {
	echo "Downloading Uninstall IKEv2 Plus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_IKEV2PLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_openvpnplus() {
	echo "Downloading Uninstall OpenVPN Plus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_OPENVPNPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_installtorplus() {
	echo "Downloading Uninstall TORPlus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_INSTALLTORPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_installsshplus() {
	echo "Downloading Uninstall SSHPlus components..."
	cd /tmp && rm -f uninstall_sshplus.sh && wget -q "$URL_UNINSTALL_INSTALLSSHPLUS" -O uninstall_sshplus.sh && chmod +x uninstall_sshplus.sh && sh uninstall_sshplus.sh
}

uninstall_warp() {
	echo "Downloading Uninstall Warp+ components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_WARP" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_warpplusplus() {
	echo "Downloading Uninstall Warp++ components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_WARPPLUSPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_openclashplus() {
	echo "Downloading Uninstall OpenClash Plus components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_OPENCLASHPLUS" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_linuxtinydesktop() {
	echo "Downloading Uninstall Linux Tiny Desktop components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_LINUXTINYDESKTOP" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_installauroratheme() {
	echo "Downloading Uninstall Aurora Theme components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_INSTALLAURORATHEME" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}

uninstall_installargontheme() {
	echo "Downloading Uninstall Argon Theme components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_INSTALLARGONTHEME" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}
# --- Dynamic Uninstall Functions End ---


# --- Static Functions (Do not edit these) ---

change_repo() {
	echo "Changing to PeDitX Repo..."
	# Add actual commands here in the future
	echo "Repository change function is a placeholder."
}

install_wol() {
	echo "Installing Wake On Lan..."
	opkg update
	opkg install luci-app-wol
	echo "Wake On Lan installed successfully."
}

cleanup_memory() {
	echo "Cleaning up memory..."
	sync && echo 3 > /proc/sys/vm/drop_caches
	echo "Memory cleanup complete."
}

self_update_view() {
	echo "--- Starting Store UI Self-Update ---"
	VIEW_FILE_PATH="/usr/lib/lua/luci/view/serviceinstaller/main.htm"
	VIEW_FILE_URL="https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/services/main.htm"
	TEMP_FILE="/tmp/main.htm.new"

	echo "Downloading latest UI from GitHub..."
	wget -q "$VIEW_FILE_URL" -O "$TEMP_FILE"

	if [ $? -eq 0 ] && [ -s "$TEMP_FILE" ]; then
		echo "Download successful."
		echo "Replacing old file at ${VIEW_FILE_PATH}"
		mv "$TEMP_FILE" "$VIEW_FILE_PATH"
		if [ $? -eq 0 ]; then
			echo "Store UI updated successfully!"
			echo "Please clear your browser cache and refresh the LuCI page."
		else
			echo "[ERROR] Failed to move the new file. Check permissions."
			rm -f "$TEMP_FILE"
		fi
	else
		echo "[ERROR] Failed to download the new UI file. Please check your internet connection."
		rm -f "$TEMP_FILE"
	fi
	echo "--- UI Update Finished ---"
}


# --- Main Execution Block ---
case "$ACTION" in
# --- Dynamic Cases Start ---
	install_installdnsjumper) install_installdnsjumper ;;
	uninstall_installdnsjumper) uninstall_installdnsjumper ;;
	install_pxnotifier) install_pxnotifier ;;
	uninstall_pxnotifier) uninstall_pxnotifier ;;
	install_installaircast) install_installaircast ;;
	uninstall_installaircast) uninstall_installaircast ;;
	install_adguardhome) install_adguardhome ;;
	uninstall_adguardhome) uninstall_adguardhome ;;
	install_netdata) install_netdata ;;
	uninstall_netdata) uninstall_netdata ;;
	install_nextcloud) install_nextcloud ;;
	uninstall_nextcloud) uninstall_nextcloud ;;
	install_plexmediaserver) install_plexmediaserver ;;
	uninstall_plexmediaserver) uninstall_plexmediaserver ;;
	install_homeassistant) install_homeassistant ;;
	uninstall_homeassistant) uninstall_homeassistant ;;
	install_homebridge) install_homebridge ;;
	uninstall_homebridge) uninstall_homebridge ;;
	install_mosquittomqtt) install_mosquittomqtt ;;
	uninstall_mosquittomqtt) uninstall_mosquittomqtt ;;
	install_nodered) install_nodered ;;
	uninstall_nodered) uninstall_nodered ;;
	install_portainer) install_portainer ;;
	uninstall_portainer) uninstall_portainer ;;
	install_docker) install_docker ;;
	uninstall_docker) uninstall_docker ;;
	install_wireguardplus) install_wireguardplus ;;
	uninstall_wireguardplus) uninstall_wireguardplus ;;
	install_l2tpplus) install_l2tpplus ;;
	uninstall_l2tpplus) uninstall_l2tpplus ;;
	install_sstpplus) install_sstpplus ;;
	uninstall_sstpplus) uninstall_sstpplus ;;
	install_ikev2plus) install_ikev2plus ;;
	uninstall_ikev2plus) uninstall_ikev2plus ;;
	install_openvpnplus) install_openvpnplus ;;
	uninstall_openvpnplus) uninstall_openvpnplus ;;
	install_installtorplus) install_installtorplus ;;
	uninstall_installtorplus) uninstall_installtorplus ;;
	install_installsshplus) install_installsshplus ;;
	uninstall_installsshplus) uninstall_installsshplus ;;
	install_warp) install_warp ;;
	uninstall_warp) uninstall_warp ;;
	install_warpplusplus) install_warpplusplus ;;
	uninstall_warpplusplus) uninstall_warpplusplus ;;
	install_openclashplus) install_openclashplus ;;
	uninstall_openclashplus) uninstall_openclashplus ;;
	install_amneziawg) install_amneziawg ;;
	install_iranips) install_iranips ;;
	install_linuxtinydesktop) install_linuxtinydesktop ;;
	uninstall_linuxtinydesktop) uninstall_linuxtinydesktop ;;
	install_carbonpx) install_carbonpx ;;
	install_peditx) install_peditx ;;
	install_installauroratheme) install_installauroratheme ;;
	uninstall_installauroratheme) uninstall_installauroratheme ;;
	install_installargontheme) install_installargontheme ;;
	uninstall_installargontheme) uninstall_installargontheme ;;
# --- Dynamic Cases End ---

# --- Static Cases (Do not edit these) ---
	change_repo) change_repo ;;
	install_wol) install_wol ;;
	cleanup_memory) cleanup_memory ;;
	self_update_view) self_update_view ;; 
	*) exit 1 ;; # Exit if action is not found
esac

exit 0

