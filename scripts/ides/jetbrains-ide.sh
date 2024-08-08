#!/usr/bin/bash

set -e

# jetbrains toolbox IDEs path
jFolder="$HOME/.JBIDEs"
# workspace for IDE
ws="1"

case "$(basename "$0")" in
  phpstorm)
    jFolder="${jFolder}"/phpstorm
    jexec=bin/phpstorm.sh
  ;;
  phpstorm-stable)
    jFolder="${jFolder}"/phpstorm-stable
    jexec=bin/phpstorm.sh
  ;;
  phpstorm-eap)
    jFolder="${jFolder}"/phpstorm-eap
    jexec=bin/phpstorm.sh
  ;;
  clion)
    jFolder="${jFolder}"/CLion
    jexec=bin/clion.sh
  ;;
  goland)
    jFolder="${jFolder}"/Goland
    jexec=bin/goland.sh
  ;;
  idea-u)
    jFolder="${jFolder}"/IDEA-U
    jexec=bin/idea.sh
  ;;
  pycharm)
    jFolder="${jFolder}"/PyCharm-P
    jexec=bin/pycharm.sh
  ;;
  rider)
    jFolder="${jFolder}"/Rider
    jexec=bin/rider.sh
  ;;
  rubymine)
    jFolder="${jFolder}"/RubyMine
    jexec=bin/rubymine.sh
  ;;
  webstorm)
    jFolder="${jFolder}"/WebStorm
    jexec=bin/webstorm.sh
  ;;
  datagrip)
    ws="2"
    jFolder="${jFolder}"/datagrip
    jexec=bin/datagrip.sh
  ;;
  android|android-studio)
    jFolder="${jFolder}"/android-studio
    jexec=bin/studio.sh
  ;;
  aqua)
    jFolder="${jFolder}"/aqua
    jexec=bin/aqua.sh
  ;;
  dataspell)
    jFolder="${jFolder}"/dataspell
    jexec=bin/dataspell.sh
  ;;
  fleet)
    jFolder="${jFolder}"/fleet
    jexec=bin/Fleet
  ;;
  gateway)
    jFolder="${jFolder}"/gateway
    jexec=bin/gateway.sh
  ;;
  idea-c|intellij-idea-community-edition)
    jFolder="${jFolder}"/intellij-idea-community-edition
    jexec=bin/idea.sh
  ;;
  mps)
    jFolder="${jFolder}"/mps
    jexec=bin/mps.sh
  ;;
  pycharm-c|pycharm-community)
    jFolder="${jFolder}"/pycharm-community
    jexec=bin/pycharm.sh
  ;;
  rustrover)
    jFolder="${jFolder}"/rustrover
    jexec=bin/rustrover.sh
  ;;
  space|space-desktop)
    jFolder="${jFolder}"/space-desktop
    jexec=space
  ;;
  writerside)
    jFolder="${jFolder}"/writerside
    jexec=bin/writerside.sh
  ;;
  *) exit ;;
esac

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

ideFolder="$(find "${jFolder}" -mindepth 1 -maxdepth 1 -type d -o -type l | sort -h | tail -n 1 | tr -d '\n')"
if [ -z "${ideFolder}" ]; then
  echo "folder '${jFolder}' was empty" 1>&2
  exit
fi

# vm options file
vmopts="${ideFolder}.vmoption"
if [ ! -f "${vmopts}" ] || [ "$(echo -ne "${desired_vmopts_content}" | sha1sum - | cut -d ' ' -f1 | tr -d '\n')" != "$(sha1sum "$vmopts" | cut -d ' ' -f1 | tr -d '\n')" ]; then
  echo -ne "${desired_vmopts_content}" >"$vmopts"
fi

if [ "$#" -ge 2 ] && [ "$1" != "--line" ]; then
  # pass all args run command and exit
  "${ideFolder}/${jexec}" "$@"
  exit
fi


"${ideFolder}/${jexec}" "$@"
