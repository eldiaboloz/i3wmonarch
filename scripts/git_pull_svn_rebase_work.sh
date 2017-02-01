#!/bin/bash
startdir=`pwd`
for x in `find /work/www -mindepth 2 -maxdepth 2 -name ".git" -type d`; do
    cd $x/../
	echo "Repo : $(basename $(pwd))"

	gitcb=$(git rev-parse --abbrev-ref HEAD)
	if [ "$gitcb" != "master" ]; then
		echo "on brach $gitcb so skipping!!!"
		continue
	fi
	git stash -u
       	git pull origin master
       	git svn fetch
       	git svn rebase
	git stash pop
	cd $startdir
done
