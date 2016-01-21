#!/bin/bash
deftarget=github.com
echo $deftarget
if [ "$#" -eq 2 ]; then
	echo "2 args: " "$1" "$2"
	git submodule add https://github.com/$1/$2.git $deftarget/$1/$2
elif [ "$#" -eq 1  ];then
	if [[ "$1" =~ (https://github.com/(.*)/(.*)\.git) ]]; then
		git submodule add $1 $deftarget/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}
	fi
else
	echo "Github Clone helper Usage: "
	echo "1 Arg : clone url"
	echo "2 Args: user repo"
fi

