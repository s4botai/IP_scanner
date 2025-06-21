#!/bin/bash

# Colours
Red='\033[0;31m'
Green='\033[0;32m'
Orange='\033[0;33m'
NC='\033[0m'

banner=$(cat << 'EOF'
 ___ ____    ____                                  
|_ _|  _ \  / ___|  ___ __ _ _ __  _ __   ___ _ __ 
 | || |_) | \___ \ / __/ _` | '_ \| '_ \ / _ \ '__|
 | ||  __/   ___) | (_| (_| | | | | | | |  __/ |   
|___|_|     |____/ \___\__,_|_| |_|_| |_|\___|_|   
                                                   
EOF
)

help_panel=$( cat << 'EOF'
Description: 
  This script will filter for all the alive IPs of a file containing IP ranges. It will also scan for open ports on the alive IPs.

Options:
  -f <file>   File with all the IP ranges
  -h, --help  Show this help panel

Example: 
  ./ip_scanner.sh -f file_with_ip_ranges
EOF
)


function check_dependencies(){
  echo -e "\n[${Orange}${NC}] Checking for dependencies..."
  /usr/bin/sleep 2  
  pkgs='prips'
  for pkg in $pkgs; do
    status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
    if [[ ! $? -eq 0 || ! "$status" = "installed" ]]; then
      echo -e "\n[${Red}${NC}] Package $pkg not installed, please install it with 'sudo apt install $pkg' and run the tool again."
      exit 1
    else
      echo -e "\n[${Green}${NC}] All dependencies installed"
    fi
  done

}

function main(){
  file=$1
  /usr/bin/mkdir output 2>/dev/null
  if [[ $(echo $?) -eq 0 ]]; then
    echo -e "\n[${Orange}${NC}] Getting all IPs from $file... "
    while read ip; do
      /usr/bin/prips $ip 
    done < "$file" > output/all_ips.txt
    /usr/bin/sleep 2

    echo -e "\n[${Orange}${NC}] Filtering for alive IPs, this can take a while..."
    /usr/bin/nmap -iL output/all_ips.txt -sn -oG alive_scan.gnmap > /dev/null
    grep "Status: Up" alive_scan.gnmap | awk '{print $2}' > output/alive_ips.txt
    rm alive_scan.gnmap
    ALIVE_IPS=$(wc -l < output/alive_ips.txt)

    echo -e "\n[${Orange}${NC}] Alive IPs: $ALIVE_IPS"

    if [[ $ALIVE_IPS -eq 0 ]]; then
      echo -e "\n[${Orange}${NC}] No alive IPs detected, exiting..."
      exit 2
    fi
  
    /usr/bin/sleep 1

    echo -e "\n[${Orange}${NC}] Scanning top ports 1000 on every alive IP..."
    nmap -iL output/alive_ips.txt -n -Pn --open --top-ports 1000 -oA output/nmap_open_ports > /dev/null
    /usr/bin/sleep 2

    echo -e "\n[${Orange}${NC}] Scanning complete. Check the output folder"
    echo -e "\n[${Orange}${NC}] Files generated:\n"
    echo -e "  alive_ips.txt          (alive IPs)"
    echo -e "  nmap_open_ports.nmap   (legible)"
    echo -e "  nmap_open_ports.gnmap  (grepable)"
    echo -e "  nmap_open_ports.xml    (XML for processing)"
  else
    echo -e "\n[${Red}${NC}]Error: Failed to create 'output' directory, check if the directory already exists or you may not have enough permissions. Exiting..."
    exit 1
  fi
}

if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then

  echo -e "\n$help_panel"

elif [[ "$1" == "-f" ]]; then
  if [[ -z "$2" ]]; then
    echo -e "\n[${Red}${NC}] Error: The -f parameter requieres a file"
  elif [[ ! -f "$2" ]]; then
    echo -e "\n[${Red}${NC}] Error: File $2 not found"
  else
    echo -e "$banner"
    echo -e "\n\t\tMade by s4botai"
    check_dependencies
    main $2
  fi

fi
