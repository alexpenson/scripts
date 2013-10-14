
#!/bin/bash
### ./tumor-normal-tview.sh ARC < file.vcf
### stdin must have: chr <TAB> pos <TAB> ...
### prints tviews of tumor and normal samples starting at given position 
### and with:
width=30
offset=10

samtools=/ifs/scratch/c2b2/rr_lab/shares/samtools/samtools ### development version
ref_samtools_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/Illumina_iGenome/Homo_sapiens/Ensembl/GRCh37/Sequence/BWAIndex/genome.fa

function list_join { 
    local OLDIFS=$IFS
    IFS=${1:?"Missing separator"}; shift
    echo "$*"
    IFS=$OLDIFS
}

# if [[ $# -eq 2 ]]; then
#     N1=$1; shift			### bam file
#     N2=$1; shift
#     tumor=$(echo /ifs/scratch/c2b2/rr_lab/shares/GGP/*/*/GRCh37_*_GGP-$N1.pe.MarkDuplicates.bam)
#     normal=$(echo /ifs/scratch/c2b2/rr_lab/shares/GGP/*/*/GRCh37_*_GGP-$N2.pe.MarkDuplicates.bam)
# elif [[ $# -eq 4 ]]; then
    declare -a bam_files
    for patient in "$@"; do
# 	bam=$(echo /ifs/scratch/c2b2/rr_lab/shares/GGP/*/*/GRCh37_*_GGP-$N.pe.MarkDuplicates.bam)
# 	bam_files=("${bam_files[@]}" $bam)
	bam=$(echo /ifs/scratch/c2b2/rr_lab/shares/GGP/links_duplicates/$patient-*.bam)
	bam_files=("${bam_files[@]}" $bam)
    done
#fi

echo "${bam_files[@]}"

while read line; do
    if [[ ${line:0:1} = "#" ]]; then continue; fi
    ### split line by tab
    array=(${line//\t/})
    ### assume chr:pos if there is a colon in the first field
    if [[ ${array[0]} == *:* ]]; then
	first_field=${array[0]}
	chrpos=("${first_field//:/}")
	chr=${chrpos[0]}
	integer pos=${chrpos[1]}
	echo pos $chrpos
    
    else
    ### else assume chr pos are the first two fields
	chr=${array[0]}
	integer pos=${array[1]}
    fi
    pos=$(( $pos - $offset ))
    pos=$chr:$pos

    echo $pos
    tput bold
    tput setaf 4 ### blue
    echo $line
    tput sgr0
#	if [[ $# -eq 4 ]]; then
    (
#        echo $(list_join "@" "${bam_files[@]}")
	echo "b@n1@n2@t1@t2"
        paste -d"@" \
            <(printf '%'$offset'sV\n';$samtools tview -d text -p $pos ${bam_files[0]}  $ref_samtools_genome | cut -c1-$width) \
            <(printf '%'$offset'sV\n';$samtools tview -d text -p $pos ${bam_files[1]}  $ref_samtools_genome | cut -c1-$width) \
            <(printf '%'$offset'sV\n';$samtools tview -d text -p $pos ${bam_files[2]}  $ref_samtools_genome | cut -c1-$width) \
            <(printf '%'$offset'sV\n';$samtools tview -d text -p $pos ${bam_files[3]}  $ref_samtools_genome | cut -c1-$width) \
            <(printf '%'$offset'sV\n';$samtools tview -d text -p $pos ${bam_files[4]}  $ref_samtools_genome | cut -c1-$width) \
            ) \
	    | sed ':x s/\(^\|@\)@/\1 @/; t x' | column -ts$"@"
# 	else
# 	    (
# 		echo 'TUMOR@NORMAL';
# #	    printf '%'$offset'sV@%'$offset'sV\n';'
# 		paste -d"@" \
#                     <( $samtools tview -d text -p $pos $tumor  $ref_samtools_genome | cut -c1-$width) \
#                     <( $samtools tview -d text -p $pos $normal  $ref_samtools_genome | cut -c1-$width) \
#                     ) \
# 		    | sed 's/^@/\ @/' | column -ts$"@"
# 	fi
done

### echo *.dat | sed 's/\S*/<(cut -f2 &)/g; s/^/paste /' | bash >all.dat
