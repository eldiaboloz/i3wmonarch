#!/usr/bin/env bash 
trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    echo -n "$var"
}
mobo=$(trim $(dmidecode -t 2 | grep -e 'Product Name:.*' | cut -d ':' -f2))
cpu=$(trim $(dmidecode -t 4 | grep -e 'Version:.*' | cut -d ':' -f2))
ram=$(trim $(dmidecode -t 17 | grep -e 'Size: ' | grep -v -- 'No Module Installed' | cut -d ':' -f2 | sort | uniq -c))
ramtype=$(trim $(dmidecode -t 17 | grep -e 'Type: ' | grep -v -- 'Unknown' | cut -d ':' -f2 | sort | uniq))
maxram=$(trim $(dmidecode -t 16 | grep 'Maximum Capacity:' | cut -d ':' -f2))

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# check fro both AMD and ATI
lspci | grep -P 'VGA compatible controller:.*(AMD|ATI)' 1>/dev/null 2>&1 && gpured=Y || gpured=N
# check for both VGA and 3D (no video output) for nvidia
lspci | grep -P '(3D controller:|VGA compatible controller:).*NVIDIA' 1>/dev/null 2>&1 && gpugreen=Y || gpugreen=N
# Intel is lowercase it seems
lspci | grep -P 'VGA compatible controller:.*Intel' 1>/dev/null 2>&1 && gpublue=Y || gpublue=N

echo "MB: $mobo"
echo "CPU: $cpu"
echo "RAM: $ram | max: $maxram | type: $ramtype"
echo -e "GPU: ${RED}${gpured}${NC} ${GREEN}${gpugreen}${NC} ${BLUE}${gpublue}${NC}"

# pass arg to include sensors output
[ -z "$1" ] && exit

sensors
[[ "$gpugreen" == "Y" ]] && command -v nvidia-smi 2>/dev/null 1>&2 && nvidia-smi
