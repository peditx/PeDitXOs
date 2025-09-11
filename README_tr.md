# PeDitXOS Araçları

## Dil Seçimi:

[**English**](README.md) | [**فارسی**](README_fa.md) | [**中文**](README_zh.md) | [**Русский**](README_ru.md) | [**Türkçe**](README_tr.md)

![PeDitX Banner](https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/brand.png)

---

## 🚀 PeDitXOS Nedir?
**PeDitXOS**, OpenWrt cihazınızı güçlü, modern ve kullanıcı dostu bir ağ geçidine dönüştüren bir betik koleksiyonudur.

- **OpenVPN, Xray, V2Ray, WireGuard ve Cloudflare Warp** gibi birden fazla protokol için yerel destek
- Bölümlere ayrılmış ve kesintisiz trafik yönlendirmesi ile istikrarlı bir internet bağlantısı için **Passwall 1 ve Passwall 2**'yi (ayrı ayrı veya aynı anda) yükleyin
- Aktif olarak sürdürülen ve sürekli güncellenen proje

---

## ✨ Özellikler
- **Tek Tıkla Grafiksel Kurulum**: İlk kurulumdan sonra LuCI'de kolay kurulum
- **Tam Otomatik Kurulum**: Tek bir komutla her şey çalışır durumda
- **Çift Passwall Desteği**: Passwall 1 ve 2'yi aynı yönlendiricide eş zamanlı olarak çalıştırın
- **Kolay Exroot**: Tek tıkla depolama alanını genişletin (USB varsa)
- **X86 Araçları**: Linux x86/x64'ü güçlü bir OpenWrt yönlendiriciye dönüştürün
- **Hızlı Wi-Fi Kurulumu**: Sadece SSID ve şifre girerek Wi-Fi'yi yapılandırın
- **Bellek Temizleyici**: Tek tıkla RAM'i boşaltın
- **Ek Paketler**: OpenVPN, Sing-box, SoftEther ve daha fazlası (512MB'den büyük depolama alanı için)
- **Akıllı XRAY Kurulumu**: Depolama sınırlıysa XRAY'i tmpfs üzerine kurar
- **Optimize Edilmiş Yönlendirme**: Daha iyi performans için İran IP/alan adları için doğrudan yönlendirme
- **Performans Geliştirmeleri**: Yeni tema, düzeltilmiş WARP, varsayılan kill switch, XRAY Fragment TLS Hello

---

## 📡 Desteklenen Protokoller

| Protokol | XRAY Çekirdeği | SING-BOX Çekirdeği |
| :--- | :---: | :---: |
| **VLESS** | ✅ | ✅ |
| **VMESS** | ✅ | ✅ |
| **REALITY** | ✅ | ❌ |
| **TROJAN** | ✅ | ✅ |
| **HYSTERIA2** | ❌ | ✅ |
| **TUIC** | ❌ | ✅ |
| **Shadowsocks** | ✅ | ✅ |
| **WireGuard** | ✅ | ✅ |
| **SOCKS** | ✅ | ✅ |
| **HTTP** | ✅ | ✅ |

---

## 📶 Önerilen Yönlendiriciler
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

## ⚡ Hızlı Kurulum
Hızlı kurulum için yönlendiricinizin SSH terminalinde aşağıdaki komutu çalıştırın:

```bash
sh -c "$(curl -sL https://peditxos.ir/install)"
```

Bu adımdan sonra, gelecekteki tüm yönetim işlemleri LuCI web arayüzü üzerinden yapılabilir.

🏗️ Firmware Oluşturucu
Çevrimiçi hizmetimizi kullanarak resmi PeDitXOS eklentileriyle kendi özel OpenWrt firmware imajınızı oluşturun:

👉 [Oluşturmaya Başla](https://peditxos.ir)  

---

🙏 Özel Teşekkürler

- [PeDitX](https://github.com/peditx)  
- [PeDitXRT](https://github.com/peditx/peditxrt)  
- [OpenWrt](https://github.com/openwrt)  
- [ImmortalWrt](https://github.com/immortalwrt)  
- [Bootstrap Theme](https://github.com/twbs/bootstrap) 

© 2018–2025 PeDitX. Tüm hakları saklıdır.
Destek veya sorularınız için Telegram üzerinden bize katılın.
