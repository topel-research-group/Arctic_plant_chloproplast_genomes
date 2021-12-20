#!/bin/bash

grep ">" P*/*.ffn |cut -f2 -d" " | sort | uniq -c |sort -nr
