#!/bin/bash
gene_name=$1; shift
region=$1; shift
for input_bam in "$@"; do 
    output_bam=$(basename ${input_bam/.bam/.$gene_name.bam})    
    samtools view -b $input_bam $region > $output_bam
    samtools index $output_bam
done