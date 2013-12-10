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
str=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
data=data_$str
mkfifo $data
windows=windows_$str
mkfifo $windows

/ifs/scratch/c2b2/rr_lab/shares/samtools/samtools view -b $input_bam $chr > $data &
/ifs/scratch/c2b2/rr_lab/shares/tabix/tabix $tabixed_bed $chr > $windows &

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/nfs/apps/gcc/4.6.0/lib64
/ifs/scratch/c2b2/rr_lab/shares/bedtools/bin/bedtools coverage \
    -abam $data \
    -b $windows \
    -split \
    -counts \
    | /ifs/scratch/c2b2/rr_lab/shares/bedtools/bin/bedtools sort \
    > $output_prefix.$chr.bed

### REMOVE NAMED PIPES
rm $data
rm $windows
