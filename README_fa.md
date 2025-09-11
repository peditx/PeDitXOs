# PeDitXOS Tools  

## Language Selection:

[**English**](README.md) | [**فارسی**](README_fa.md) | [**中文**](README_zh.md) | [**Русский**](README_ru.md)

![PeDitX Banner](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)  

---

## 🚀 What is PeDitXOS?  
**PeDitXOS** مجموعه‌ای از اسکریپت‌هاست که دستگاه OpenWrt شما را به یک گیت‌وی قدرتمند، مدرن و آسان برای استفاده تبدیل می‌کند.  

- پشتیبانی بومی از پروتکل‌های متنوع مانند **OpenVPN، Xray، V2Ray، WireGuard و Cloudflare Warp**  
- نصب **Passwall 1 و Passwall 2** (به صورت جداگانه یا همزمان) برای اینترنت پایدار با مسیریابی پیوسته و تفکیک‌شده  
- توسعه فعال و به‌روزرسانی مداوم پروژه  

---

## ✨ Features  
- **نصب گرافیکی یک‌کلیکی**: نصب ساده در LuCI پس از راه‌اندازی اولیه  
- **راه‌اندازی خودکار کامل**: تنها با یک دستور  
- **پشتیبانی همزمان Passwall 1 و 2** روی یک روتر  
- **Easy Exroot**: افزایش فضای ذخیره‌سازی با یک کلیک (در صورت وجود USB)  
- **ابزارهای X86**: تبدیل لینوکس x86/x64 به روتر قدرتمند OpenWrt  
- **راه‌اندازی سریع Wi-Fi** تنها با وارد کردن SSID و رمز عبور  
- **پاک‌سازی حافظه RAM** با یک کلیک  
- **پکیج‌های اضافه**: OpenVPN، Sing-box، SoftEther و بیشتر (برای فضای >512MB)  
- **نصب هوشمند XRAY** روی tmpfs در صورت محدودیت فضای ذخیره‌سازی  
- **مسیریابی بهینه** برای آی‌پی و دامنه‌های ایران  
- **بهبود عملکرد**: پوسته جدید، WARP اصلاح‌شده، Kill Switch پیش‌فرض، XRAY Fragment TLS Hello  

---

## 📡 Supported Protocols  

| Protocol      | XRAY Core | SING-BOX Core |
|---------------|-----------|---------------|
| **VLESS**     | ✅         | ✅             |
| **VMESS**     | ✅         | ✅             |
| **REALITY**   | ✅         | ❌             |
| **TROJAN**    | ✅         | ✅             |
| **HYSTERIA2** | ❌         | ✅             |
| **TUIC**      | ❌         | ✅             |
| **Shadowsocks** | ✅       | ✅             |
| **WireGuard** | ✅         | ✅             |
| **SOCKS**     | ✅         | ✅             |
| **HTTP**      | ✅         | ✅             |

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
برای نصب سریع، دستور زیر را در ترمینال SSH روتر وارد کنید:  

```bash
sh -c "$(curl -sL https://peditxos.ir/install)"
```  

پس از این مرحله، تمام مدیریت‌ها از طریق **رابط LuCI** انجام می‌شوند.  

---

## 🏗️ Firmware Builder  
با سرویس آنلاین ما، ایمیج سفارشی OpenWrt خود را همراه با پلاگین‌های رسمی PeDitXOS بسازید:  
👉 [Start Building](https://peditxos.ir)  

---

## 🙏 Special Thanks  

- [PeDitX](https://github.com/peditx)
- [PeDitXRT](https://github.com/peditx/peditxrt)
- [OpenWrt](https://github.com/openwrt)
- [ImmortalWrt](https://github.com/immortalwrt)
- [Bootstrap Theme](https://github.com/twbs/bootstrap)



© 2018–2025 PeDitX. All rights reserved.  
For support or inquiries, join us on [Telegram](https://t.me/peditx).
