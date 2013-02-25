#!/bin/bash
source="${1:-/proc/${$}/fd/0}"
filename="${1-read.fastq}"
filebase="${filename%.*}"
extension="${filename##*.}"
file1="$filebase.1.$extension"
file2="$filebase.2.$extension"
awk '{
  print substr($0,1,length/2) > "'"$file1"'"
  print substr($0,1+length/2,length/2) > "'"$file2"'"
}' < "$source"