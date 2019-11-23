#!/usr/bin/bash

set -e

# jetbrains toolbox IDEs path
jfolder="$HOME/.local/share/JetBrains/Toolbox/apps"
# current symlink name
jname=$(basename "$0")
# default channel to use
jch=0

case "$jname" in
    clion*)
        jfolder="${jfolder}/CLion"
        jexec=clion
    ;;
    goland*)
        jfolder="${jfolder}/Goland"
        jexec=goland
    ;;
    idea-u*)
        jfolder="${jfolder}/IDEA-U"
        jexec=idea
    ;;
    phpstorm*)
        # prefer EAP builds for phpstorm ( installed on ch-1 )
        jch=1
        jfolder="${jfolder}/PhpStorm"
        jexec=phpstorm
    ;;
    pycharm*)
        jfolder="${jfolder}/PyCharm-P"
        jexec=pycharm
    ;;
    rider*)
        jfolder="${jfolder}/Rider"
        jexec=rider
    ;;
    rubymine*)
        jfolder="${jfolder}/RubyMine"
        jexec=rubymine
    ;;
    webstorm*)
        jfolder="${jfolder}/WebStorm"
        jexec=webstorm
    ;;
    datagrip*)
        jfolder="${jfolder}/datagrip"
        jexec=datagrip
    ;;
    android*|studio*)
        jfolder="${jfolder}/AndroidStudio"
        jexec=studio.sh
    ;;
    *)
        chooseide=$(cd "$jfolder";find "." -mindepth 5 -maxdepth 5 -type f -regex '.*/[0-9]+\.[0-9]+\(\.[0-9]+\)?/bin/.*.sh$' | grep -v 'inspect.sh\|format.sh' | sort | fzf)
        [ -z "$chooseide" ] && exit 1
        jshfile="$jfolder/$chooseide"
    ;;
esac

if [ -z "$jshfile" ]; then
    # force channel to use
    [[ "$jname" == *_ch0* ]] && jch="0"
    [[ "$jname" == *_ch1* ]] && jch="1"
    [[ "$jname" == *_ch2* ]] && jch="2"
    # folder where IDE is installed
    jfolder="${jfolder}/ch-${jch}"

    # check if channel exists
    [ ! -d "$jfolder" ] && { echo "no such channel!" 1>&2;exit 1;}

    # by default select latest version from channel
    [[ "$jname" == *_r ]] && jord="" || jord="-r"

    # find the installed version 
    jver=$(find "${jfolder}" -mindepth 1 -maxdepth 1 -type d | xargs -I{} basename "{}"| grep -v '.plugins' |  sort $jord | sed -n 1p)

    # locate IDE sh file first
    jshfile=$(realpath "$jfolder/$jver/bin/$jexec.sh")
fi

# .sh file was not found
if [ -z "$jshfile" ]; then
    echo "$jshfile was not found" 1>&2
    exit 1
fi

# vm options file
vmopts="$(echo "$jshfile" | rev | cut -d '/' -f3- | rev).vmoptions"

if ! { [ -f "$vmopts" ] \
    && [ "156e11c397ed8b5406dd45861cecadb1a3b29b6d" == "$(sha1sum "$vmopts" | cut -d ' ' -f1 | tr -d '\n')" ]; }; then
# customize settings - set country/language and give more RAM
cat > "$vmopts" << EOF
-Xms128m
-Xmx2048m
-XX:ReservedCodeCacheSize=240m
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-Dsun.io.useCanonCaches=false
-Djava.net.preferIPv4Stack=true
-Djdk.http.auth.tunneling.disabledSchemes=""
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-Dawt.useSystemAAFontSettings=lcd
-Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine
-Dide.no.platform.update=true
-Duser.country=BG
-Duser.language=bg
-XX:MaxJavaStackTraceDepth=10000
EOF
fi

# start the executable
nohup "$jshfile" "$@" >/dev/null 2>&1 &

if [ "$#" -eq 0 ]; then
    sleep 3
else
    sleep 1
fi

if [[ "$jshfile" == *datagrip.sh* ]]; then
    i3-msg "workspace 2; layout stacked" >/dev/null 2>&1
else
    i3-msg "workspace 1; layout stacked" >/dev/null 2>&1
fi
