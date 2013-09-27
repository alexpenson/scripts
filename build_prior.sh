#!/bin/bash

input_1p_file=$1; shift

function build_prior {
    /ifs/home/c2b2/rr_lab/shares/scripts/savi/savi_poster -p $1 | /ifs/home/c2b2/rr_lab/shares/scripts/savi/savi_poster_accum
}

prior=/ifs/home/c2b2/rr_lab/shares/scripts/savi/unif_prior01
for i in {1..10}; do 
    new_prior=prior$i
    echo "building $new_prior using $prior"
    build_prior $prior < $input_1p_file > $new_prior
    prior=$new_prior
done
