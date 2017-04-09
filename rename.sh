#!/bin/bash
k=1
for i in *.mp4; do
	new =$(printf"%d.mp4" "$k")
	mv-- "$i" "$new"
	letk=k+1
done
