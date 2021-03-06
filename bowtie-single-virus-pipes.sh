#!/bin/bash
#$ -pe smp 8
#$ -t 1-10

in_fastq_1=$1; shift
in_fastq_2=$1; shift
out_bam=$1; shift
ref_virus=${1-/ifs/scratch/c2b2/rr_lab/avp2106/pathogen/refs/TYP1.fa}
ref_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19
ref_transcriptome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta

job=$SGE_TASK_ID

#############################################
mkfifo in.$job.fq
cat $in_fastq_1 $in_fastq_2 | paste - - - - | sed -n $job'~10p' | tr '\t' '\n' > in.$job.fq &

#############################################
mkfifo fqtrim.$job.seq
(/ifs/scratch/c2b2/rr_lab/shares/fqtrim-0.92/fqtrim -p 2 -DV - | paste - - - - | cut -f2) < in.$job.fq > fqtrim.$job.seq &

#############################################
mkfifo genome_unmapped.$job.seq
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_genome \
    -r -U fqtrim.$job.seq \
    --very-fast-local \
    | samtools view -Sf4 - | cut -f10 > genome_unmapped.$job.seq &

#############################################
mkfifo transcriptome_unmapped.$job.seq
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_transcriptome \
    -r -U genome_unmapped.$job.seq \
    --very-fast-local \
    | samtools view -Sf4 - | cut -f10 > transcriptome_unmapped.$job.seq &

#############################################
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_virus \
    -r -U transcriptome_unmapped.$job.seq \
    --very-sensitive \
    | samtools view -SbF4 - > out.$job.bam