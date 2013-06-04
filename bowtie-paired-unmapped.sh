#!/bin/bash
#$ -pe smp 4
ref=${4-/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19}
#ref=${4-/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta}
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 4 -x $ref -q \
    -1 $1 \
    -2 $2 \
    --un-conc $3 \
    --local > /dev/null
