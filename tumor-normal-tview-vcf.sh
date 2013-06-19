#!/bin/bash
### ./tumor-normal-tview.sh ARC < file.vcf
### stdin must have: chr <TAB> pos <TAB> ...
### prints tviews of tumor and normal samples starting at given position 
### and with:
width=30
offset=10

samtools=/ifs/scratch/c2b2/rr_lab/shares/samtools/samtools ### development version
ref_samtools_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/samtools_faidx/hg19.fa

# sample=$1; shift
# tumor=/ifs/scratch/c2b2/rr_lab/shares/MDS_DATA/combined/Columbia-Naomi-Exome/bam/${sample}-1.recal.bam 
# normal=/ifs/scratch/c2b2/rr_lab/shares/MDS_DATA/combined/Columbia-Naomi-Exome/bam/${sample}-2.recal.bam 

tumor_bam=$1; shift
normal_bam=$1; shift

while read line; do
    if [[ ${line:0:1} = "#" ]]; then continue; fi
    array=(${line//\t/})
    chr=${array[0]}
    pos=${array[1]}
    pos=$(( $pos - $offset ))
    pos=$chr:$pos
    tput bold
    tput setaf 4 ### blue
    echo $line
    tput sgr0
    (
	echo 'TUMOR@NORMAL';
	printf '%'$offset'sV@%'$offset'sV\n';
	paste -d"@" \
	    <($samtools tview -d text -p $pos $tumor_bam  $ref_samtools_genome | cut -c1-$width) \
	    <($samtools tview -d texy -p $pos $normal_bam $ref_samtools_genome | cut -c1-$width) \
	    ) \
    | sed 's/^@/\ @/' | column -ts$"@"
done
