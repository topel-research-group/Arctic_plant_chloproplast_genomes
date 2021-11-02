#!/bin/bash
for x in ./*.gz; do
  dir=$(echo $x | cut -c 33-41);
  mkdir -p "$dir"; 
  mv $x $dir
done
