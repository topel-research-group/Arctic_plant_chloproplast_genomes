#!/bin/bash

# This script will execute unzip all files in each subdirectory from where it was executed
# Warning: Use with CAUTION. 

HERE=`pwd`

for DIR in `find . -type d`
do
cd $DIR
find . -type f -name '*.zip' -exec unzip {} \;
cd $HERE
done
