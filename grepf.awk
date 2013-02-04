#!/bin/awk -f
NR == FNR {a[$0]; next} !($0 in a)
