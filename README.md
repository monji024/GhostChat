

<div align="center">
  <h1>GhostChat</h1>
  <p><strong> GHOSTCHAT </strong></p>
  
  <a href="https://github.com/monji024/ghostchat">
    <img src="https://img.shields.io/badge/version-1.0-green?style=flat-square" alt="Version">
  </a>
  <a href="https://github.com/monji024/ghostchat/stargazers">
    <img src="https://img.shields.io/github/stars/monji024/ghostchat?style=flat-square" alt="GitHub Stars">
  </a>
  <a href="https://github.com/monji024/ghostchat/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/monji024/ghostchat?style=flat-square" alt="MIT License">
  </a>
  <a href="https://github.com/monji024/ghostchat">
    <img src="https://img.shields.io/github/last-commit/monji024/ghostchat?style=flat-square" alt="Last Commit">
  </a>
  <a href="https://github.com/monji024/ghostchat">
    <img src="https://img.shields.io/github/languages/top/monji024/ghostchat?style=flat-square" alt="Bash">
  </a>
</div>

<br>

> **"زبان سرخ، سر سبز را به باد می‌دهد."**  
>

<br>


# [ ABOUT ]

GhostChat is a lightweight, secure, peer-to-peer messaging tool
that works over local network (LAN) or globally via tunneling.
All messages are encrypted using AES-256-CBC with PBKDF2 key
derivation. No central server, no databases, no tracking.



# [ REQUIREMENTS ]

- bash 4.0 or higher
- openssl (for encryption)
- netcat (nc) (for network communication)
- curl (for ngrok API)
- base64 (for encoding)
- ngrok (optional - for global mode)


# [ INSTALLATION ]

```ruby
   git clone https://github.com/monji024/ghostchat.git
   cd ghostchat
```
```ruby
   chmod +x ghostchat.sh
```
3. Install dependencies (if missing):

   Debian/Ubuntu:
   ```bash
   sudo apt install openssl netcat curl
   ```
   Arch Linux:
   ```bash
   sudo pacman -S openssl gnu-netcat curl
   ```
   macOS:
   ```bash
   brew install openssl netcat curl
   ```
4. (Optional) Install ngrok for global mode:
```bash
   wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
   tar -xzf ngrok-v3-stable-linux-amd64.tgz
   sudo mv ngrok /usr/local/bin/
```

# [ Usage ]

Run the script:
```bash
./ghostchat.sh
```


# [ Local Network (LAN) ]

Computer A (Host):
$ ./ghost.sh
Username: Dariush
Choice: 1
Room password: secret123
Your local IP: 192.168.1.100

Computer B (Join):
$ ./ghost.sh
Username: siavash
Choice: 2
Host IP: 192.168.1.100
Room password: secret123

Now Dariush and siavash can chat securely.


# [ Global (Ngrok)]

Computer A (Host):
$ ./ghostchat.sh
Username: Dariush
Choice: 3
Room password: secret123
Ngrok auth token: 2u6V23aJXQZdxFpY1U5EjSokT8t_...
Address: tcp://0.tcp.ngrok.io:12345

Computer B (Join from anywhere):
$ ./ghostchat.sh
Username: siavash
Choice: 4
Global address: tcp://0.tcp.ngrok.io:12345
Room password: secret123

Now Dariush and siavash can chat securely over internet.



# [ LICENSE ]

MIT License


# [ DISCLAIMER ]

This software is provided "as is", without warranty of any kind.
Use at your own risk. The author is not responsible for any misuse
or damage caused by this software.


# [ CONTACT ]

Telegram: @DevCrr
GitHub: https://github.com/monji024


