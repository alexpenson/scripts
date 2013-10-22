#!/bin/bash

input_bam=$1; shift
prefix=$(basename $input_bam .bam)

picard=/ifs/scratch/c2b2/rr_lab/shares/picard/dist
java -Xmx4G -jar $picard/CalculateHsMetrics.jar \
    BAIT_INTERVALS=Probes.interval_list \
    TARGET_INTERVALS=Regions.interval_list \
    R=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/Illumina_iGenome/Homo_sapiens/Ensembl/GRCh37/Sequence/LexicographicallySorted/genome.fa \
    I=$input_bam \
    O=$prefix.HsMetrics.txt \
    PER_TARGET_COVERAGE=$prefix.HsMetrics_per_target.txt \
    VALIDATION_STRINGENCY=LENIENT
