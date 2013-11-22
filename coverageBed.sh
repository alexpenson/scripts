#!/bin/bash
#$ -t 1-25
#$ -l mem=2G,time=2::

input_bam=$1; shift
tabixed_bed=$1; shift
output_prefix=$1; shift

# create input regions file ($tabixed_bed)
# bgzip regions.bed
# tabix -p bed $regions.bed.gz
# https://github.com/samtools/tabix

### CHOOSE CHROMOSOME
case $SGE_TASK_ID in
    23) region="X";;
    24) region="Y";;
    25) region="MT";;
    X) region="23";;
    Y) region="24";;
    MT) region="25";;
    *) region=$SGE_TASK_ID	
esac
chr=chr$region
echo $chr

### NAMED PIPES
mkfifo $input_bam.$chr.fifo
mkfifo $tabixed_bed.$chr.fifo

/ifs/scratch/c2b2/rr_lab/shares/samtools/samtools view -b $input_bam $chr > data &
/ifs/scratch/c2b2/rr_lab/shares/tabix/tabix $tabixed_bed $chr > windows &

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/nfs/apps/gcc/4.6.0/lib64
/ifs/scratch/c2b2/rr_lab/shares/bedtools/bin/bedtools coverage \
    -abam $input_bam.$chr.fifo \
    -b $tabixed_bed.$chr.fifo \
    -split \
    -counts \
    > $output_prefix.$chr.bed

### REMOVE NAMED PIPES
rm $input_bam.$chr.fifo
rm $tabixed_bed.$chr.fifo
