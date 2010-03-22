#!/bin/bash

for F in region_*climber*685.tsv ; do
    
    for S in 01 12 23 ; do

	G=${F%%.tsv}_$S.tsv

	cat $F | awk -v S=$S '

/^#/     { print }
/^[0-9]/ { print $1,$2/23,$(S+2) }
' > $G

    done

done 
