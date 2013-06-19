#!/bin/bash
#$ -pe smp 4

in_fastq_1=$1; shift
in_fastq_2=$1; shift
out_sam=$1; shift
ref_virus=${1-/ifs/scratch/c2b2/rr_lab/avp2106/pathogen/refs/TYP1.fa}
ref_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19
ref_transcriptome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta

#############################################
genome_suffix=genome_unmapped.fastq
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 4 -x $ref_genome -q \
    -1 <(pv -n $in_fastq_1) \
    -2 $in_fastq_2 \
    --un-conc R%.$genome_suffix \
    --local > /dev/null

#############################################
transcriptome_suffix=transcriptome_unmapped.fastq
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 4 -x $ref_transcriptome -q \
    -1 R1.$genome_suffix \
    -2 R2.$genome_suffix \
    --un-conc R%.$transcriptome_suffix \
    --local > /dev/null

#############################################
fqtrim_suffix=${transcriptome_suffix/fastq/fqtrim.fastq}
/ifs/scratch/c2b2/rr_lab/shares/fqtrim-0.92/fqtrim -DV R1.$transcriptome_suffix,R2.$transcriptome_suffix -o fqtrim.fastq

#############################################
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2/bowtie2 -p 4 -x $ref_virus -q \
    -1 R1.$fqtrim_suffix \
    -2 R2.$fqtrim_suffix \
    --local \
    | samtools view -SF4 - > $out_sam 
