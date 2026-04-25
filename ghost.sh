#!/bin/bash

# author : Monji
# telegram : https://t.me/DevCrr
# GitHub : https://github.com/monji024

VERSION="1.0"
PORT=5555
CONFIG_DIR="$HOME/.ghostchat"
mkdir -p "$CONFIG_DIR"


RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

cleanup() {
    pkill -P $$ 2>/dev/null
    rm -f /tmp/ghost_*_$$ 2>/dev/null
    stty sane 2>/dev/null
    exit 0
}
trap cleanup INT TERM EXIT

banner() {
    clear
    echo -e "${CYAN}
   ██████╗  ██╗  ██╗ ██████╗ ███████╗████████╗ 
   ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
   ██║  ███╗███████║██║   ██║███████╗   ██║   
   ██║   ██║██╔══██║██║   ██║╚════██║   ██║  
   ╚██████╔╝██║  ██║╚██████╔╝███████╗   ██║  
    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝    
    ${NC}"
    echo -e "      ${YELLOW}Ghost Chat v${VERSION}${NC}\n"
}

encrypt() { 
    echo -n "$1" | openssl enc -aes-256-cbc -pbkdf2 -pass pass:"$2" 2>/dev/null | base64 -w0
}

decrypt() { 
    echo "$1" | base64 -d 2>/dev/null | openssl enc -aes-256-cbc -d -pbkdf2 -pass pass:"$2" 2>/dev/null
}


get_username() {
    echo -ne "${CYAN}[?] Your username: ${NC}"
    read username
    [[ -z "$username" ]] && username="Anonymous"
}

show_ip() {
    my_ip=$(ip route get 1 2>/dev/null | awk '{print $7;exit}')
    [[ -z "$my_ip" ]] && my_ip="127.0.0.1"
    echo -e "${CYAN}[🌐] Your local IP: ${my_ip}${NC}"
}


host_local() {
    local pass
    echo -ne "${CYAN}[?] Room password: ${NC}"; read -s pass; echo
    show_ip
    echo -e "${CYAN}[*] Local host started on port $PORT${NC}"
    echo -e "${YELLOW}[!] Share your local IP and password with friends${NC}"
    echo -e "${CYAN}[*] Waiting for connection...${NC}\n"

    pipe_in="/tmp/ghost_in_$$"
    pipe_out="/tmp/ghost_out_$$"
    mkfifo "$pipe_in" "$pipe_out"

    nc -l -p "$PORT" < "$pipe_in" | while IFS= read -r line; do
        decrypted=$(decrypt "$line" "$pass")
        if [[ -n "$decrypted" ]]; then
            sender="${decrypted%%||*}"
            msg="${decrypted#*||}"
            printf "\r\033[K"
            echo -e "${CYAN}[${sender}] > ${msg}${NC}"
            echo -en "${CYAN}[${username}] > ${NC}"
        fi
    done &

    exec 3> "$pipe_in"
    while true; do
        read -p "$(echo -e "${CYAN}[${username}] > ${NC}")" msg
        if [[ "$msg" == "exit" ]]; then
            break
        fi
        payload="${username}||${msg}"
        echo "$(encrypt "$payload" "$pass")" > "$pipe_in"
    done
    exec 3>&-

    kill %1 2>/dev/null
    rm -f "$pipe_in" "$pipe_out"
    echo -e "${YELLOW}[!] Connection closed.${NC}"
    sleep 1
}

join_local() {
    local host_ip pass
    echo -ne "${CYAN}[?] Host IP (local): ${NC}"; read host_ip
    echo -ne "${CYAN}[?] Room password: ${NC}"; read -s pass; echo
    clear
    echo -e "${CYAN}[✓] Connected to $host_ip:$PORT${NC}"
    echo -e "${CYAN}[*] You can now chat securely. Type 'exit' to quit.${NC}\n"

    pipe_in="/tmp/ghost_in_$$"
    pipe_out="/tmp/ghost_out_$$"
    mkfifo "$pipe_in" "$pipe_out"

    nc "$host_ip" "$PORT" < "$pipe_in" | while IFS= read -r line; do
        decrypted=$(decrypt "$line" "$pass")
        if [[ -n "$decrypted" ]]; then
            sender="${decrypted%%||*}"
            msg="${decrypted#*||}"
            printf "\r\033[K"
            echo -e "${CYAN}[${sender}] > ${msg}${NC}"
            echo -en "${CYAN}[${username}] > ${NC}"
        fi
    done &

    exec 3> "$pipe_in"
    while true; do
        read -p "$(echo -e "${CYAN}[${username}] > ${NC}")" msg
        if [[ "$msg" == "exit" ]]; then
            break
        fi
        payload="${username}||${msg}"
        echo "$(encrypt "$payload" "$pass")" > "$pipe_in"
    done
    exec 3>&-

    kill %1 2>/dev/null
    rm -f "$pipe_in" "$pipe_out"
    echo -e "${YELLOW}[!] Disconnected.${NC}"
    sleep 1
}


host_ngrok() {
    local pass token
    echo -ne "${CYAN}[?] Room password: ${NC}"; read -s pass; echo
    echo -ne "${CYELLOW}[?] Enter your ngrok auth token: ${NC}"; read -s token; echo
    echo -e "${CYAN}[*] Starting ngrok on port $PORT...${NC}"
    
    ngrok tcp "$PORT" --authtoken "$token" > /dev/null 2>&1 &
    local ngrok_pid=$!
    sleep 4

    local url=""
    for i in {1..12}; do
        url=$(curl -s http://localhost:4040/api/tunnels | grep -o 'tcp://[0-9a-z.-]*:[0-9]*' | head -1)
        [[ -n "$url" ]] && break
        sleep 1
    done

    if [[ -z "$url" ]]; then
        echo -e "${RED}[!] Ngrok failed. Check token and internet.${NC}"
        kill $ngrok_pid 2>/dev/null
        return
    fi

    clear
    echo -e "${GREEN}[✓] Global host ready!${NC}"
    echo -e "${YELLOW}[🌍] Share this address: $url${NC}"
    echo -e "${CYAN}[*] Waiting for connection...${NC}\n"

    pipe_in="/tmp/ghost_in_$$"
    pipe_out="/tmp/ghost_out_$$"
    mkfifo "$pipe_in" "$pipe_out"

    nc -l -p "$PORT" < "$pipe_in" | while IFS= read -r line; do
        decrypted=$(decrypt "$line" "$pass")
        if [[ -n "$decrypted" ]]; then
            sender="${decrypted%%||*}"
            msg="${decrypted#*||}"
            printf "\r\033[K"
            echo -e "${CYAN}[${sender}] > ${msg}${NC}"
            echo -en "${CYAN}[${username}] > ${NC}"
        fi
    done &

    exec 3> "$pipe_in"
    while true; do
        read -p "$(echo -e "${CYAN}[${username}] > ${NC}")" msg
        if [[ "$msg" == "exit" ]]; then
            break
        fi
        payload="${username}||${msg}"
        echo "$(encrypt "$payload" "$pass")" > "$pipe_in"
    done
    exec 3>&-

    kill %1 $ngrok_pid 2>/dev/null
    rm -f "$pipe_in" "$pipe_out"
    echo -e "${YELLOW}[!] Connection closed.${NC}"
    sleep 1
}


join_ngrok() {
    local addr host_ip host_port pass
    echo -ne "${CYAN}[?] Global address : ${NC}"; read addr
    host_ip=$(echo "$addr" | cut -d':' -f1 | sed 's/tcp:\/\///')
    host_port=$(echo "$addr" | cut -d':' -f2)
    echo -ne "${CYAN}[?] Room password: ${NC}"; read -s pass; echo
    clear
    echo -e "${CYAN}[✓] Connected to $host_ip:$host_port${NC}"
    echo -e "${CYAN}[*] You can now chat securely. Type 'exit' to quit.${NC}\n"

    pipe_in="/tmp/ghost_in_$$"
    pipe_out="/tmp/ghost_out_$$"
    mkfifo "$pipe_in" "$pipe_out"

    nc "$host_ip" "$host_port" < "$pipe_in" | while IFS= read -r line; do
        decrypted=$(decrypt "$line" "$pass")
        if [[ -n "$decrypted" ]]; then
            sender="${decrypted%%||*}"
            msg="${decrypted#*||}"
            printf "\r\033[K"
            echo -e "${CYAN}[${sender}] > ${msg}${NC}"
            echo -en "${CYAN}[${username}] > ${NC}"
        fi
    done &

    exec 3> "$pipe_in"
    while true; do
        read -p "$(echo -e "${CYAN}[${username}] > ${NC}")" msg
        if [[ "$msg" == "exit" ]]; then
            break
        fi
        payload="${username}||${msg}"
        echo "$(encrypt "$payload" "$pass")" > "$pipe_in"
    done
    exec 3>&-

    kill %1 2>/dev/null
    rm -f "$pipe_in" "$pipe_out"
    echo -e "${YELLOW}[!] Disconnected.${NC}"
    sleep 1
}

main_menu() {
    while true; do
        banner
        get_username
        echo
        echo -e " ${CYAN}[1]${NC} Host - Local (LAN)"
        echo -e " ${CYAN}[2]${NC} Join - Local (LAN)"
        echo -e " ${CYAN}[3]${NC} Host - Global (ngrok)"
        echo -e " ${CYAN}[4]${NC} Join - Global (ngrok)"
        echo -e " ${CYAN}[5]${NC} Exit"
        echo -ne "${YELLOW}[?] Choose: ${NC}"
        read choice
        case $choice in
            1) host_local ;;
            2) join_local ;;
            3) host_ngrok ;;
            4) join_ngrok ;;
            5) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

for cmd in openssl nc curl base64; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}[!] Missing: $cmd. Please install.${NC}"
        exit 1
    fi
done

main_menu
