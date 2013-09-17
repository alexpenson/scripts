#!/bin/bash
for input_report in "$@"; do
    /ifs/scratch/c2b2/rr_lab/avp2106/scripts/normal.sh < $input_report > ${input_report/.txt/.normal.txt}
    /ifs/scratch/c2b2/rr_lab/avp2106/scripts/AnnotCosmic.sh < ${input_report/.txt/.normal.txt} > ${input_report/.txt/.normal.cosmic.txt}
    /ifs/scratch/c2b2/rr_lab/avp2106/scripts/format_del.sh < ${input_report/.txt/.normal.cosmic.txt} > ${input_report/.txt/.normal.cosmic.format_del.txt}
done