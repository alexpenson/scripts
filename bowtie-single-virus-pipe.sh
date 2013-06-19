#!/bin/bash
#$ -pe smp 8
###$ -t 1-10

in_fastq_1=$1; shift
in_fastq_2=$1; shift
out_bam=$1; shift
ref_virus=${1-/ifs/scratch/c2b2/rr_lab/avp2106/pathogen/refs/TYP1.fa}
ref_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19
ref_transcriptome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta

job=1
##job=$SGE_TASK_ID

#############################################
#cat $in_fastq_1 $in_fastq_2 | paste - - - - | sed -n $job'~10p' | tr '\t' '\n' \
#    | /ifs/scratch/c2b2/rr_lab/shares/fqtrim-0.92/fqtrim -p 2 -DV - | paste - - - - | cut -f2 \
cat $in_fastq_1 $in_fastq_2 \
    | /ifs/home/c2b2/rr_lab/shares/bin/prinseq-lite-0.19.5/prinseq-lite.pl -fastq stdin -out_good stdout -out_bad null -lc_method dust -lc_threshold 30 \
    | paste - - - - | cut -f2 \
    | /ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_genome -r -U - --very-fast-local \
    | samtools view -Sf4 - | cut -f10 \
    | /ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_transcriptome -r -U - --very-fast-local \
    | samtools view -Sf4 - | cut -f10 \
    | /ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_virus -r -U - --very-sensitive \
    | samtools view -SbF4 > pipe.out.$job.bam
