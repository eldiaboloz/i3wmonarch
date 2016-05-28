#!/bin/bash
startdir=`pwd`
for x in `find /work/www -mindepth 2 -maxdepth 2 -name ".git" -type d`; do
       	cd $x/../
	echo "Repo : $(basename $(pwd))"
	git stash -u
	git svn rebase && git push origin master
	git stash pop
	echo ""
done
cd "$startdir"
