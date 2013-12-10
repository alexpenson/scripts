#!/bin/bash
usage="./bwa.sh db.fa reads1.fq reads2.fq out.bam"

db=$1; shift
reads1=$1; shift
reads2=$1; shift

temp_string=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c10)

aln1=bwa_$temp_string.1.sai
aln2=bwa_$temp_string.2.sai

bam=bwa_$temp_string.bam

#############################################
### BWA

bwa aln $db $reads1 > $aln1
bwa aln $db $reads2 > $aln2
bwa sampe $db $aln1 $aln2 $reads1 $reads2 \
    | samtools view -Sb - \
    > $bam

if [[ $? -ne 0 ]];then
   print "bwa sampe failed" >&2
   exit 2
fi

rm $aln1 $aln2

#############################################
### SORT

samtools sort $bam ${out/.bam/}

if [[ $? -ne 0 ]];then
   print "samtools sort failed" >&2
   exit 2
fi

rm $bam

#############################################
### INDEX

samtools index $out