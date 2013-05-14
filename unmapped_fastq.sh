#!/bin/bash
### takes bam
### writes unmapped fastq to current directory
input=$1; shift
output_prefix=$(basename $input .bam)

### BAMTOOLS
fq=$output_prefix.fq 
samtools view -bf4 $input | \
/ifs/scratch/c2b2/rr_lab/shares/bamtools/bin/bamtools convert -format fastq > $fq

### PICARD
### header error
# mem=${1-1}; shift
# fq1=$output_prefix.1.fq 
# fq2=$output_prefix.2.fq 
# java -Xmx${mem}g -jar /ifs/scratch/c2b2/rr_lab/shares/picard/dist/ReorderSam.jar INPUT=$input OUTPUT=/dev/stdout REFERENCE=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bwa/genome/hg19.fa | \
# samtools view -f4 - | \
# java -Xmx${mem}g -jar /ifs/scratch/c2b2/rr_lab/shares/picard/dist/SamToFastq.jar INPUT=/dev/stdin FASTQ=$fq1 SECOND_END_FASTQ=$fq2
