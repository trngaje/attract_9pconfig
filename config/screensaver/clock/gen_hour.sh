#!/bin/bash
for i in {0..59}; do
	let deg=i*6
	echo $deg
	convert hour_white.png \( +clone -background transparent -rotate $deg \) -gravity center -compose Src -composite  hour$i.png
#-resize 100x100
done
