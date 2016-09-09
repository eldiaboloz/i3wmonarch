#!/bin/bash
for i in $(seq 1 2000)
do
	if [ "$i" -eq 1264 ]; then
			echo "skipping gif 1264"
			continue
	fi
#	echo "on file $i"
	if [ -f "/work/tmp/xkcd/$i" ]; then
		if [ ! -f "/work/tmp/xkcd/imgs/$i.jpg" ]; then
			theimage=$(cat /work/tmp/xkcd/$i | grep "Image URL (for hotlinking/embedding):" | grep -o "http://.*" )
			if [ $? -ne 0 ]; then
				echo "skipping $i becase no match was found"
				continue
			fi
			theimageFile=$(basename $theimage)
			wget "$theimage" --output-document "/tmp/$theimageFile"
			convert "/tmp/$theimageFile" /work/tmp/xkcd/imgs/$i.jpg
			rm -v "/tmp/$theimageFile"
		fi
	fi
done
