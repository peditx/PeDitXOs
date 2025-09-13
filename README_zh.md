# PeDitXOS Tools  

## 语言选择:

[**English**](README.md) | [**فارسی**](README_fa.md) | [**中文**](README_zh.md) | [**Русский**](README_ru.md) | [**Türkçe**](README_tr.md) | [**العربية**](README_ar.md)

![PeDitX Banner](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)  

---

## 🚀 什么是 PeDitXOS?  
**PeDitXOS** 是一组脚本，可将您的 OpenWrt 设备转换为功能强大、现代化且易于使用的网关。  

- 原生支持多种协议：**OpenVPN、Xray、V2Ray、WireGuard、Cloudflare Warp**  
- 支持安装 **Passwall 1 和 Passwall 2**（可单独或同时使用）实现稳定网络和分流路由  
- 项目持续维护和更新  

---

## ✨ 功能特点  
- **一键图形化安装**：初始设置后可在 LuCI 中轻松安装  
- **全自动配置**：只需一条命令  
- **双 Passwall 支持**：同一台路由器同时运行 Passwall 1 和 2  
- **Easy Exroot**：支持 USB 一键扩展存储  
- **X86 工具**：将 Linux x86/x64 转换为强大的 OpenWrt 路由器  
- **快速 Wi-Fi 设置**：只需输入 SSID 和密码  
- **内存清理器**：一键释放 RAM  
- **额外软件包**：OpenVPN、Sing-box、SoftEther 等（需要 >512MB 存储）  
- **智能 XRAY 安装**：在存储有限时自动安装到 tmpfs  
- **优化路由**：为伊朗 IP/域名提供直连优化  
- **性能优化**：新主题、修复的 WARP、默认 Kill Switch、XRAY Fragment TLS Hello  

---

## 📡 支持的协议  

| 协议           | XRAY Core | SING-BOX Core |
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

## 📶 推荐路由器  
- x86/64
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

## ⚡ 快速安装  
在路由器的 SSH 终端中运行以下命令：  

```bash
sh -c "$(curl -sL https://peditxos.ir/install)"
```  

完成此步骤后，所有管理可通过 **LuCI 网页界面** 完成。  

---

## 🏗️ 固件构建器  
使用我们的在线服务，构建包含 PeDitXOS 官方插件的自定义 OpenWrt 固件镜像：  
👉 [开始构建](https://peditxos.ir)  

---

## 🙏 特别感谢  

- [PeDitX](https://github.com/peditx)  
- [PeDitXRT](https://github.com/peditx/peditxrt)  
- [OpenWrt](https://github.com/openwrt)  
- [ImmortalWrt](https://github.com/immortalwrt)  
- [Bootstrap Theme](https://github.com/twbs/bootstrap)
- [Mohamadreza Broujerdi](https://t.me/MR13_B)
- [Sia7ash](https://github.com/Sia7ash)
 

---

© 2018–2025 PeDitX. 版权所有。  
支持与咨询请加入 [Telegram](https://t.me/peditx)。  
