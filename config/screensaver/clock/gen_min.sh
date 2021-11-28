#!/bin/bash
for i in {0..59}; do
	let deg=i*6
	echo $deg
	convert minute_white.png \( +clone -background transparent -rotate $deg \) -gravity center -compose Src -composite  min$i.png
#-resize 100x100
done
