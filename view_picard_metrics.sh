#!/bin/bash
echo -ne "\t"
sed -n 7p $1
for i in "$@"; do
    sed -n '8s/^/'$i'\t/p' $i
done
