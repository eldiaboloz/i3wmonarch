#!/usr/bin/env bash

source /usr/bin/env_parallel.bash

radio_darik ()  { mpc add "http://darikradio.by.host.bg:8000/S2-128"; } 
radio_energy ()  { mpc add "http://stream.radioreklama.bg:80/nrj.aac"; } 
radio_focus_varna ()  { mpc add "http://online.focus-radio.net:8100/varna"; } 
radio_njoy ()  { mpc add "http://46.10.150.123:80/njoy.mp3"; } 
radio_eilo_techno ()  { mpc add "http://eilo.org:8000/techno"; } 
radio_eilo_hard ()  { mpc add "http://eilo.org:8000/hard"; } 
radio_eilo_dubstep ()  { mpc add "http://eilo.org:8000/dubstep"; } 
radio_eilo_drum ()  { mpc add "http://eilo.org:8000/drum"; } 
radio_eilo_house ()  { mpc add "http://eilo.org:8000/house"; } 
#radio_bgradio ()  { mpc add "http://stream.radioreklama.bg:80/bgradio.aac"; } 
radio_capital_london ()  { mpc add "http://media-sov.musicradio.com:80/CapitalMP3"; } 
radio_city ()  { mpc add "http://stream.radioreklama.bg:80/city.aac"; } 
#radio_antena ()  { mpc add "http://antena.hothost.bg"; } 
radio_radio1 ()  { mpc add "http://stream.radioreklama.bg:80/radio1.aac"; } 
radio_radio1rock ()  { mpc add "http://stream.radioreklama.bg:80/radio1rock.aac"; } 
radio_millenium ()  { mpc add "http://radiomillenium.radiomillenium.eu:8000/millenium-low"; } 
radio_vibesradio ()  { mpc add "http://vibesradio.org:8000/hifi"; } 
radio_fmreceiver ()  { mpc add "http://play.fmreceiver.eu:8000/fmreceiver-low"; } 
radio_trafficradio ()  { mpc add "http://radio.networx-bg.com:8002/"; } 
radio_radio33 ()  { mpc add "http://www.radio33.org:8000/"; } 
radio_radiocoolbeats ()  { mpc add "http://67.212.166.178:7024/"; } 

if [ ! -z "$1" ]; then
    radio_"$1"
else
    declare -F | cut -d ' ' -f3 | grep "^radio" | env_parallel -P 1 "{}"
fi
