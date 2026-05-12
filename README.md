


<div align="center">

# Ghost Chat

[![English](https://img.shields.io/badge/English-README-blue)](README.md)
[![Persian](https://img.shields.io/badge/Persian-README-green)](README-fa.md)

![Ruby](https://img.shields.io/badge/Ruby-2.5+-red)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-2.7-blue)

**A secure group chat room with AES-256-CBC encryption supporting LAN and global connections**


</div>

## Features

- 🔐 **End-to-End Encryption** with AES-256-CBC and PBKDF2
- 🌐 **Local (LAN)** and **Global (Ngrok)** connections
- 👥 **Group chat** with real-time online user count
- 🎨 **Beautiful CLI interface**
- 📊 **Status bar** showing IP, port, online count, and username
- 🚀 **Runs on Linux, macOS, and WSL**
- 🔌 **Ngrok support** for internet connections
- ⚡ **Lightweight and fast** - no database required

## 📋 Prerequisites

- **Ruby** version 2.5 or higher
- **Ngrok** (only for global connections)
- Operating System: Linux, macOS, or WSL on Windows

<div align="center">

![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
![WSL](https://img.shields.io/badge/WSL-0a7b9a?style=flat&logo=windows&logoColor=white)

</div>

## Install Ruby

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install ruby-full

# macOS
brew install ruby

# Windows (WSL)
wsl --install
sudo apt update && sudo apt install ruby-full
```
## Install Ngrok
```bash
# Download and install
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
sudo mv ngrok /usr/local/bin/
```
# Set your auth token
**ngrok authtoken YOUR_TOKEN**

## Direct Download
```bash

git clone https://github.com/monji024/ghostchat.git
cd ghostchat
ruby ghostchat.rb
```
## User Guide
# Main Menu
```text

[1] Host - Local (LAN)     ← Host on local network
[2] Join - Local (LAN)     ← Connect to local network
[3] Host - Global (ngrok)  ← Host globally
[4] Join - Global (ngrok)  ← Connect globally
[5] Exit                   ← Exit
```

Usage Scenarios
## 1️⃣ LAN Chat

- Host:

   - Select option [1] Host - Local

   - Enter room password

   - Share your local IP with friends

- Friends:

   - Select option [2] Join - Local

   - Enter host IP and password

   - Start chatting :)

## 2️⃣ Global Chat (via Internet)

- Host:

   - Select option [3] Host - Global (ngrok)

   - Enter room password

   - Enter your Ngrok auth token

   - Share the public address (e.g., tcp://0.tcp.ngrok.io:12345) with friends

- Friends:

   - Select option [4] Join - Global (ngrok)

   - Enter public address and password

   - Start chatting :)

- 🔒 Security

   - ✅ AES-256-CBC encryption - Global standard

   - ✅ PBKDF2 - Standard compliant

   - ✅ End-to-End encryption - Messages only readable with password

   - ✅ No message storage - Messages never saved to disk

   - ✅ Password authentication - Only password holders can join

## 🛠 Technical Architecture
# Project Structure

```text

ghostchat/
├── ghostchat.rb      # Main application file
├── README-fa.md      # Persian documentation
├── README.md         # English documentation
└── LICENSE           # License
```
- Core Components

   - Crypto - Encryption management

   - ChatServer - Chat server (connection management & message broadcasting)

   - ChatClient - Chat client (send and receive messages)

   - StatusBar - Status bar (display information)

   - NgrokManager - Ngrok tunnel management

# 🐛 Troubleshooting
**Issue: require 'openssl' failed**
```bash

# Ubuntu/Debian
sudo apt install libssl-dev
gem install openssl
```
# Issue: Port 5550 is in use

**The program automatically frees the port. If not:**
```bash

# Linux/macOS
fuser -k 5550/tcp
# OR
lsof -ti :5550 | xargs kill -9
```
# Issue: Garbled/weird characters

** Make sure your terminal supports UTF-8: **
```bash

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```
- Issue: Ngrok connection not working

   - Make sure ngrok is installed: which ngrok

   - Set your auth token: ngrok authtoken YOUR_TOKEN

   - Check your internet connection

## 🤝 Contributing

**I'd be happy if you contribute to improving this project**

## Connect

- **GitHub**: [![GitHub](https://img.shields.io/badge/GitHub-monji024-181717?style=flat-square&logo=github)](https://github.com/monji024)
- **Project**: [![Repo](https://img.shields.io/badge/Repository-Ghostchat-blue?style=flat-square&logo=github)](https://github.com/monji024/Ghostchat)


## License
[MIT](LICENSE) © monji
