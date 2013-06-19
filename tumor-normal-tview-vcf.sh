#!/bin/bash
### ./tumor-normal-tview.sh ARC < file.vcf
### stdin must have: chr <TAB> pos <TAB> ...
### prints tviews of tumor and normal samples starting at given position 
### and with:
width=50
offset=10

samtools=/ifs/scratch/c2b2/rr_lab/shares/samtools/samtools ### development version
ref_samtools_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/samtools_faidx/hg19.fa

# sample=$1; shift
# tumor=/ifs/scratch/c2b2/rr_lab/shares/MDS_DATA/combined/Columbia-Naomi-Exome/bam/${sample}-1.recal.bam 
# normal=/ifs/scratch/c2b2/rr_lab/shares/MDS_DATA/combined/Columbia-Naomi-Exome/bam/${sample}-2.recal.bam 

tumor_bam=$1; shift
normal_bam=$1; shift

function tview {
    ### tview chr1:1000 file.bam
    $samtools tview -d text -p $1 $2 $ref_samtools_genome \
	| awk ' \
FNR==2{  \
    str=substr($0,1,'$offset'); \
    gsub(/[A-Za-z]/,"", str); \
    new_offset='$offset'+length(str)+2; \
    printf "%"new_offset"s", "V\n"  \
} \
{ \
    print \
}' \
	| cut -c1-$width 
}

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
#	printf '%'$offset'sV@%'$offset'sV\n';
	paste -d"@" \
	    <(tview $pos $tumor_bam) \
	    <(tview $pos $normal_bam) \
	    ) \
    | sed 's/^@/\ @/' | column -ts$"@"
done

