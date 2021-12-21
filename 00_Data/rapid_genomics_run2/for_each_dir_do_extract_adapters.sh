#!/bin/bash

# This script will copy the overrepresented sequences from fastqc_data.txt files and paste them adapters.txt into the root folder
# Then it filters adaptes.txt to unique sequences and sorts it alphabetically by adapter name
#
# Warning: Use with CAUTION. 

HERE=`pwd`

for DIR in `find . -type d`
do
cd $DIR
awk '/>>Overrepresented sequences/ {p=1}; p; />>END_MODULE/ {p=0}' fastqc_data.txt | head -n-1 | sed '1,2d' >> $HERE/adapters_temp.txt
cd $HERE
cut -f 1,4 adapters_temp.txt | sort | uniq | sort -k3 > adapters.txt
#rm adapters_temp.txt

done
