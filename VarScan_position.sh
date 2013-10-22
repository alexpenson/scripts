# #$ -t 1-25
#$ -l time=1::,mem=16G
ref=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/samtools_faidx/hg19.fa

#region=$1; shift
#patient=$1; shift
input_bams="$@"

### mpileup removes duplicate reads

while read region; do
    mpileup=$(samtools mpileup -d 2000 -B -q 10 -r $region -f $ref "$@" 2> /dev/null)
    if [ -z "$mpileup" ]; then
	echo -e "0\t0%"
	continue
    fi

    varscan=$(echo "$mpileup" | java -Xmx700m \
	-jar /ifs/scratch/c2b2/rr_lab/shares/VarScan/VarScan.v2.3.6.jar mpileup2cns \
	--output-vcf 1 \
	--strand-filter 0 \
	--min-var-freq 0.0001 \
	--min-coverage 1 \
	--p-value 1 \
	2> /dev/null \
	| grep -v "^#" | cut -f10 | cut -d':' -f4,7)

    if [ -z "$varscan" ]; then
        echo -e "0\t0%"
    else
	echo "$varscan" | tr ":" "\t"

    fi

done

# \
   # | java -Xmx40m \
    # -jar /ifs/scratch/c2b2/rr_lab/shares/snpEff-v3.3/SnpSift.jar extractFields - \
    # CHROM POS REF ALT "GEN[0].FREQ"