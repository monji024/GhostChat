<div dir="rtl" align="center">

# Ghost Chat

[![English](https://img.shields.io/badge/English-README-blue)](README.md)
[![Persian](https://img.shields.io/badge/Persian-README-green)](README-fa.md)


<img src="https://img.shields.io/badge/Ruby-2.5+-red.svg" alt="Ruby">
<img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
<img src="https://img.shields.io/badge/Version-2.7-blue.svg" alt="Version">

**یک چت‌روم گروهی امن با رمزنگاری AES-256-CBC و پشتیبانی از اتصالات داخلی و خارجی**


</div>

## امکانات

- 🔐 **رمزنگاری سرتاسری** با الگوریتم AES-256-CBC و PBKDF2
- 🌐 **اتصال محلی (LAN)** و **جهانی (Ngrok)**
- 👥 **چت گروهی** با قابلیت نمایش تعداد کاربران آنلاین
- 🎨 **رابط کاربری زیبا**
- 📊 **نوار وضعیت** نمایش IP، پورت، تعداد آنلاین و نام کاربری
- 🚀 **اجرا بر روی لینوکس، macOS و WSL**
- 🔌 **پشتیبانی از Ngrok** برای اتصال از اینترنت
- ⚡ **سبک و سریع** بدون نیاز به دیتابیس

## 📋 پیش‌نیازها

- **Ruby** نسخه 2.5 یا بالاتر
- **Ngrok** (فقط برای اتصال جهانی)
- سیستم عامل: لینوکس، macOS یا WSL روی ویندوز
<div dir="rtl" align="center">

![Linux](https://img.shields.io/badge/Linux-FCC624.svg?style=flat&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000.svg?style=flat&logo=apple&logoColor=white)
![WSL](https://img.shields.io/badge/WSL-0a7b9a.svg?style=flat&logo=windows&logoColor=white)

</div>

## نصب Ruby

```bash
# اوبونتو/دبیان
sudo apt update && sudo apt install ruby-full

# macOS
brew install ruby

# Windows (WSL)
wsl --install
sudo apt update && sudo apt install ruby-full
```
## نصب Ngrok
```bash

# دانلود و نصب
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/

# تنظیم توکن
ngrok authtoken YOUR_TOKEN
```
## دانلود مستقیم
```bash

git clone https://github.com/monji024/ghostchat.git
cd ghostchat
ruby ghostchat.rb
```

## راهنمای استفاده

# منوی اصلی
```text

[1] Host - Local (LAN)     ← میزبانی در شبکه محلی
[2] Join - Local (LAN)     ← اتصال به شبکه محلی
[3] Host - Global (ngrok)  ← میزبانی جهانی
[4] Join - Global (ngrok)  ← اتصال جهانی
[5] Exit                   ← خروج
```
## سناریوهای استفاده
1️⃣ چت در شبکه محلی (LAN)

- شخص میزبان:

   - گزینه [1] Host - Local را انتخاب کنید

   - رمز چت روم را وارد کنید

   - IP محلی خود را با دوستان به اشتراک بگذارید

- دوستان:

   - گزینه [2] Join - Local را انتخاب کنید

   - IP میزبان و رمز را وارد کنید

   - شروع چت:)

2️⃣ چت جهانی (از طریق اینترنت)

- شخص میزبان:

   - گزینه [3] Host - Global (ngrok) را انتخاب کنید

   - رمز چت روم را وارد کنید

   - توکن Ngrok خود را وارد کنید

   - آدرس عمومی (مثل tcp://0.tcp.ngrok.io:12345) را با دوستان به اشتراک بگذارید

- دوستان:

   - گزینه [4] Join - Global (ngrok) را انتخاب کنید

   - آدرس عمومی و رمز را وارد کنید

   - شروع چت:)


- 🔒 امنیت

   - ✅ رمزنگاری AES-256-CBC - استاندارد جهانی

   - ✅ PBKDF2 مطابق با استاندارد

   - ✅ رمزنگاری سرتاسر پیام‌ها فقط با رمز قابل خواندن هستند

   - ✅ عدم ذخیره‌سازی پیام‌ها - پیام‌ها روی دیسک ذخیره نمی‌شوند

   - ✅ احراز هویت با رمز - فقط افراد دارای رمز می‌توانند وارد شوند

## 🛠 معماری فنی
# ساختار پروژه
```text

ghostchat/
├── ghostchat.rb      # فایل اصلی برنامه
├── README-fa.md       # راهنمای فارسی
├── README.md       # راهنمای انگلیسی
└── LICENSE            # مجوز
```
- اجزای اصلی

   - Crypto - مدیریت رمزنگاری

   - ChatServer - سرور چت (مدیریت اتصالات و پخش پیام‌ها)

   - ChatClient - کلاینت چت (ارسال و دریافت پیام)

   - StatusBar - نوار وضعیت (نمایش اطلاعات)

   - NgrokManager - مدیریت تونل Ngrok

## 🐛 رفع اشکال
مشکل: require 'openssl' failed
```bash

# اوبونتو/دبیان
sudo apt install libssl-dev
gem install openssl
```
# مشکل: پورت 5550 در حال استفاده است

**برنامه به صورت خودکار پورت را آزاد می‌کند در غیر این صورت:**
```bash

# لینوکس/macOS
fuser -k 5550/tcp
# یا
lsof -ti :5550 | xargs kill -9
```
# مشکل: نمایش داده نمی‌شود (کاراکترهای عجیب)

**مطمئن شوید ترمینال شما از UTF-8 پشتیبانی می‌کند:**
```bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```
- مشکل: اتصال به Ngrok کار نمی‌کند

   - مطمئن شوید ngrok نصب است: which ngrok

   - توکن را تنظیم کنید: ngrok authtoken YOUR_TOKEN

   - اینترنت خود را چک کنید


## 🤝 مشارکت

خوشحال میشم تو بهبود این پروژه مشارکت کنید

## ارتباط با من

- **GitHub**: [![GitHub](https://img.shields.io/badge/GitHub-monji024-181717?style=flat-square&logo=github)](https://github.com/monji024)
- **Project**: [![Repo](https://img.shields.io/badge/Repository-Ghostchat-blue?style=flat-square&logo=github)](https://github.com/monji024/Ghostchat)


## مجوز
[MIT](LICENSE) © monji
