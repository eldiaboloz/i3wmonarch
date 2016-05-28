#!/bin/bash
startdir=`pwd`
for x in `find /work/www -mindepth 2 -maxdepth 2 -name ".git" -type d`; do
       	cd $x/../
	git stash -u
       	git pull origin master
       	git svn fetch
       	git svn rebase
	git stash pop
	cd $startdir
done
