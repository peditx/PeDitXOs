# PeDitXOS Tools  

## Language Selection:

[**English**](README.md) | [**فارسی**](README_fa.md) | [**中文**](README_zh.md) | [**Русский**](README_ru.md)

![PeDitX Banner](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)  

---

## 🚀 What is PeDitXOS?  
**PeDitXOS** is a collection of scripts that transforms your OpenWrt device into a powerful, modern, and user-friendly gateway.  

- Native support for multiple protocols such as **OpenVPN, Xray, V2Ray, WireGuard, and Cloudflare Warp**  
- Install **Passwall 1 and Passwall 2** (individually or simultaneously) for a stable internet connection with segmented and continuous traffic routing  
- Actively maintained and continuously updated project  

---

## ✨ Features  
- **One-Click Graphical Installation**: Easy installation in LuCI after the initial setup  
- **Fully Automatic Setup**: Everything up and running with a single command  
- **Dual Passwall Support**: Run Passwall 1 and 2 concurrently on the same router  
- **Easy Exroot**: Expand storage with one click (if USB is available)  
- **X86 Tools**: Turn Linux x86/x64 into a powerful OpenWrt router  
- **Quick Wi-Fi Setup**: Configure Wi-Fi by simply entering SSID and password  
- **Memory Cleaner**: Free up RAM with one click  
- **Extra Packages**: OpenVPN, Sing-box, SoftEther, and more (for storage >512MB)  
- **Smart XRAY Installation**: Installs XRAY on tmpfs if storage is limited  
- **Optimized Routing**: Direct routing for Iran IP/domains for better performance  
- **Performance Enhancements**: New theme, fixed WARP, default kill switch, XRAY Fragment TLS Hello  

---

## 📡 Supported Protocols  

| Protocol       | XRAY Core | SING-BOX Core |
|----------------|-----------|---------------|
| **VLESS**      | ✅         | ✅             |
| **VMESS**      | ✅         | ✅             |
| **REALITY**    | ✅         | ❌             |
| **TROJAN**     | ✅         | ✅             |
| **HYSTERIA2**  | ❌         | ✅             |
| **TUIC**       | ❌         | ✅             |
| **Shadowsocks**| ✅         | ✅             |
| **WireGuard**  | ✅         | ✅             |
| **SOCKS**      | ✅         | ✅             |
| **HTTP**       | ✅         | ✅             |

---

## 📶 Recommended Routers  
- Google WiFi (Gale)  
- Linksys EA8300 / E8450 / EA7500 / EA8100  
- Belkin rt3200  
- GL-iNet GL-A1300 / AR300M (NOR)  
- Xiaomi AX3000T / AX3600 / AX3200 / AX6000  
- TP-Link C6 v3  
- Mikrotik Hap ac2  
- ASUS RT-N66U  
- Netgear R7800  
- ~~Xiaomi 4a Gigabit~~  

---

## ⚡ Quick Install  
For quick installation, run the following command in your router’s SSH terminal:  

```bash
sh -c "$(curl -sL https://peditxos.ir/install)"
```  

After this step, all future management can be done via the **LuCI web interface**.  

---

## 🏗️ Firmware Builder  
Build your own custom OpenWrt firmware image with official PeDitXOS plugins using our online service:  
👉 [Start Building](https://peditxos.ir)  

---

## 🙏 Special Thanks  

- [PeDitX](https://github.com/peditx)  
- [PeDitXRT](https://github.com/peditx/peditxrt)  
- [OpenWrt](https://github.com/openwrt)  
- [ImmortalWrt](https://github.com/immortalwrt)  
- [Bootstrap Theme](https://github.com/twbs/bootstrap)  

This theme is based on the [Bootstrap Theme](https://github.com/twbs/bootstrap).  

---

© 2018–2025 PeDitX. All rights reserved.  
For support or inquiries, join us on [Telegram](https://t.me/peditx).  
