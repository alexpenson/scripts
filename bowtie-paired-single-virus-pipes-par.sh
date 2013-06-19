#!/bin/bash
#$ -pe smp 8
#$ -t 1-10
in_fastq_1=$1; shift
in_fastq_2=$1; shift
out_sam=$1; shift
ref_virus=${1-/ifs/scratch/c2b2/rr_lab/avp2106/pathogen/refs/TYP1.fa}
ref_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19
ref_transcriptome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta

job=$SGE_TASK_ID

#############################################
in_fastq_suffix=fastq
mkfifo R1.$job.$in_fastq_suffix R2.$job.$in_fastq_suffix
(paste - - - - | sed -n $job'~10p' | tr '\t' '\n') < $in_fastq_1 > R1.$job.$in_fastq_suffix &
(paste - - - - | sed -n $job'~10p' | tr '\t' '\n') < $in_fastq_2 > R2.$job.$in_fastq_suffix &

#############################################
genome_suffix=genome_unmapped.fastq
mkfifo R1.$job.$genome_suffix R2.$job.$genome_suffix
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_genome -q \
    -1 R1.$job.$in_fastq_suffix \
    -2 R2.$job.$in_fastq_suffix \
    --un-conc R%.$job.$genome_suffix \
    --local > /dev/null &

#############################################
transcriptome_suffix=transcriptome_unmapped.fastq
mkfifo R1.$job.$transcriptome_suffix R2.$job.$transcriptome_suffix
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_transcriptome -q \
    -1 R1.$job.$genome_suffix \
    -2 R2.$job.$genome_suffix \
    --un-conc R%.$job.$transcriptome_suffix \
    --local > /dev/null &

#############################################
fqtrim_suffix=${transcriptome_suffix/fastq/fqtrim.fastq}
mkfifo R1.$job.$fqtrim_suffix R2.$job.$fqtrim_suffix
/ifs/scratch/c2b2/rr_lab/shares/fqtrim-0.92/fqtrim -p 2 -DV R1.$job.$transcriptome_suffix,R2.$job.$transcriptome_suffix -o fqtrim.fastq &

#############################################
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 2 -x $ref_virus -q \
    -1 R1.$job.$fqtrim_suffix \
    -2 R2.$job.$fqtrim_suffix \
    --local \
    | samtools view -SF4 - > ${out_sam/.sam/.$job.sam}
