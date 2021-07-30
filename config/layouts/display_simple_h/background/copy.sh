#!/bin/bash

find ./ -type d | while read file 
do 
	cp $file/_inc/system.png $file.png
done
