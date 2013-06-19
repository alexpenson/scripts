#!/bin/bash
cat /dev/stdin  > __input_file__
paste __input_file__ <(cut -f27,28,32 __input_file__ | AnnotCosmic.py)
rm __input_file__
