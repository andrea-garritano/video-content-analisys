#!/bin/bash

i="1"
while [ $i -lt 39 ]; do
  mkdir $i 
  ffmpeg -i $i.mp4 -vf fps=1/3 $i/%d.jpg 
  i=$[$i+1]
done
