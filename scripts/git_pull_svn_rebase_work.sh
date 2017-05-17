#!/bin/bash
myname=$(basename "$0")
dopush=""
[[ "$myname" == *push_* ]] && dopush="y"
startdir=$(pwd)
if [ $# -eq 0 ]; then
    repos="$(find /work/www -mindepth 2 -maxdepth 2 -name ".git" -type d)"
else
    repos="$@"
fi
for x in $repos; do
    reponame="$(basename "$x")"
    if [ "$reponame" == "$x" ]; then
        x="/work/www/$x/.git"
    fi
    cd $x/../
    echo "Repo : $(basename $(pwd))"

    gitcb=$(git rev-parse --abbrev-ref HEAD)
    if [ "$gitcb" != "master" ]; then
        echo "on brach $gitcb so skipping!!!"
        continue
    fi

    git svn info >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        # this is not a git-svn repo
        git pull origin master
    else
        # this is a git-svn repo
        git stash -u \
            && git pull origin master \
            && git svn fetch \
            && git svn rebase \
            && ( ( [ -z "$dopush" ] && git push origin master ) || true  ) \
            && git stash pop
    fi
    echo ""
done
cd $startdir
[[ "$myname" == *float* ]] && read -n1 -r -p "Press any key..." key
