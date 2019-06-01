#!/usr/bin/env bash
rig=${BLOCK_INSTANCE:-"my.rig1"}
case $BLOCK_BUTTON in
    1) 
        xfce4-terminal -e "ssh $BLOCK_INSTANCE" --role="floatme" > /dev/null 2>&1 &
    ;;
	3)
        xfce4-terminal -e "ssh $BLOCK_INSTANCE" --role="floatme" > /dev/null 2>&1 &
    ;;
esac
printme=""
while read -r line; do
    gpu_name=$(echo "$line" | cut -d ',' -f1)
    gpu_temp=$(echo "$line" | cut -d ',' -f2 | cut -d ' ' -f2-)
    case "$gpu_name" in 
        "GeForce GTX 1070")
            gpu_type="G1"
        ;;
        "P106-100")
            gpu_type="G2"
        ;;
        "GeForce GTX 1060 6GB")
            gpu_type="G3"
        ;;
        "GeForce GTX 1060 3GB")
            gpu_type="G4"
        ;;
        "GeForce GTX 1050 Ti")
            gpu_type="G5"
        ;;
        *)
            gpu_type="G9"
        ;;
    esac
    printme="$printme $gpu_type-$gpu_temp"
done < <(ssh $rig nvidia-smi --query-gpu=name,temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
echo "$printme"
echo "$printme"
echo "#FFFFFF"
