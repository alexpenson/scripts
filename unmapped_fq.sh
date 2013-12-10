#!/bin/bash
export PATH=/ifs/scratch/c2b2/rr_lab/shares/samtools:$PATH
export PATH=/ifs/scratch/c2b2/rr_lab/shares/fqtrim-0.92:$PATH
picard=/ifs/scratch/c2b2/rr_lab/shares/picard/dist
input_bam=$1; shift
output_prefix=$(basename $input_bam .bam)

#############################################
### EXTRACT UNMAPPED READS

samtools view -u -f 4  -F 264 $input_bam > $output_prefix.unmapped_with_mapped_mate.bam
samtools view -u -f 8  -F 260 $input_bam > $output_prefix.mapped_with_unmapped_mate.bam
samtools view -u -f 12 -F 256 $input_bam > $output_prefix.unmapped_with_unmapped_mate.bam

#############################################
### MERGE UNMAPPED BAMS

samtools merge -u - \
    $output_prefix.unmapped_with_mapped_mate.bam \
    $output_prefix.mapped_with_unmapped_mate.bam \
    $output_prefix.unmapped_with_unmapped_mate.bam \
    | samtools sort -n - $output_prefix.unmapped

rc=$?
if [[ $rc != 0 ]] ; then
    echo "Error in merge"
    exit $rc
fi

rm \
    $output_prefix.unmapped_with_mapped_mate.bam \
    $output_prefix.mapped_with_unmapped_mate.bam \
    $output_prefix.unmapped_with_unmapped_mate.bam

#############################################
### SamToFastq

java -Xmx700m -jar $picard/SamToFastq.jar \
    I=$output_prefix.unmapped.bam \
    F=$output_prefix.unmapped_1.fq \
    F2=$output_prefix.unmapped_2.fq

rc=$?
if [[ $rc != 0 ]] ; then
    echo "Error in SamToFastq"
    exit $rc
fi

rm $output_prefix.unmapped.bam

#############################################
### TRIM AND FILTER

fqtrim -D -o fqtrim.fq \
    $output_prefix.unmapped_1.fq,$output_prefix.unmapped_2.fq

rc=$?
if [[ $rc != 0 ]] ; then
    echo "Error in SamToFastq"
    exit $rc
fi

rm $output_prefix.unmapped_1.fq $output_prefix.unmapped_2.fq