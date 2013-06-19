#!/bin/bash
head -n 1; tail -n +2 | sort -k25,25 -k17,17n | format_del.pl
