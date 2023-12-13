#!/usr/bin/bash

set -e

# jetbrains toolbox IDEs path
jfolder="$HOME/.local/share/JetBrains/Toolbox/apps"
# current symlink name
jname=$(basename "$0")
# default channel to use
jch=0
ws="1"

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
idea-c*)
  jfolder="${jfolder}/IDEA-C"
  jexec=idea
  ;;
phpstorm*)
  # prefer EAP builds for phpstorm ( installed on ch-1 )
  #  jch=1
  jfolder="${jfolder}/PhpStorm"
  jexec=phpstorm
  ;;
pycharm-c)
  jfolder="${jfolder}/PyCharm-C"
  jexec=pycharm
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
  ws="2"
  ;;
android* | studio*)
  jfolder="${jfolder}/AndroidStudio"
  jexec=studio
  ;;
jb-gateway|jet-brains-gateway)
  jfolder="${jfolder}/JetBrainsGateway"
  jexec=gateway
  ;;
*)
  ideslist="$(
    cd "$jfolder"
    find -L "." -mindepth 5 -maxdepth 5 -type f -regex '.*[0-9]+\.[0-9]+\(\.[0-9]+\)?/bin/.*.sh$' |
      grep -v 'inspect.sh\|format.sh\|ltedit.sh\|remote-dev-server.sh\|game-tools.sh\|profiler.sh' | sort
  )"
  [ -n "${PRINT_ONLY}" ] && {
    echo "$ideslist"
    exit
  }
  [ -n "${CHOSEN_IDE}" ] || CHOSEN_IDE="$(echo "$ideslist" | fzf)"
  [ -z "${CHOSEN_IDE}" ] && exit 1
  jshfile="$jfolder/${CHOSEN_IDE}"
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
  [ ! -d "$jfolder" ] && {
    echo "no such channel!" 1>&2
    exit 1
  }

  # by default select latest version from channel
  [[ "$jname" == *_r ]] && jord="" || jord="-r"

  # find the installed version
  jver=$(find "${jfolder}" -mindepth 1 -maxdepth 1 -type d | xargs -I{} basename "{}" | grep -v '.plugins' | sort $jord | sed -n 1p)

  # locate IDE sh file first
  jshfile=$(realpath "$jfolder/$jver/bin/$jexec.sh")
fi

# .sh file was not found
if [ -z "$jshfile" ]; then
  echo "$jshfile was not found" 1>&2
  exit 1
fi

# customize settings - set country/language and give more RAM
desired_vmopts_content="$(
  cat <<'EOF'
-Xms256m
-Xmx2048m
-XX:ReservedCodeCacheSize=512m
-XX:+UseConcMarkSweepGC
-XX:SoftRefLRUPolicyMSPerMB=50
-ea
-Dsun.io.useCanonCaches=false
-Dsun.io.useCanonPrefixCache=false
-Djava.net.preferIPv4Stack=true
-Djdk.http.auth.tunneling.disabledSchemes=""
-XX:+HeapDumpOnOutOfMemoryError
-XX:-OmitStackTraceInFastThrow
-Djdk.attach.allowAttachSelf=true
-Dkotlinx.coroutines.debug=off
-XX:MaxJavaStackTraceDepth=10000
-XX:CICompilerCount=8
-Djdk.module.illegalAccess.silent=true
-Dsun.tools.attach.tmp.only=true
-Dide.no.platform.update=true
-Dawt.useSystemAAFontSettings=lcd
-Dsun.java2d.renderer=sun.java2d.marlin.MarlinRenderingEngine
-Duser.country=BG
-Duser.language=bg\n
EOF
)"

# vm options file
vmopts="$(echo "$jshfile" | rev | cut -d '/' -f3- | rev).vmoptions"
if [ ! -f "${vmopts}" ] || [ "$(echo -ne "${desired_vmopts_content}" | sha1sum - | cut -d ' ' -f1 | tr -d '\n')" != "$(sha1sum "$vmopts" | cut -d ' ' -f1 | tr -d '\n')" ]; then
  echo -ne "${desired_vmopts_content}" >"$vmopts"
fi

if [ "$#" -ge 2 ] && [ "$1" != "--line" ]; then
  # pass all args run command and exit
  "$jshfile" "$@"
  exit
fi

# prepare workspace
#i3-msg "workspace ${ws}"
#xfce4-terminal -e 'sleep 3'
#sleep 0.001
#i3-msg "layout stacked"

# start IDE
#nohup "$jshfile" "$@" &>/dev/null &
"$jshfile" "$@"


# focus IDE
#~/dev/i3wmonarch/scripts/i3wm/activate_window.sh "jetbrains-${jexec}" "stacked" "10"
