#!/bin/bash

find *.png | while read file 
do 
	convert "$file" -crop 200x360+220 "$file"
done

mogrify -resize 200x480 *.png