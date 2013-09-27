#$ -t 1-25
#$ -l time=8::,mem=4G
export SNPEFF_HOME=/ifs/scratch/c2b2/rr_lab/shares/snpEff-v3.3
export SNPEFF="-jar $SNPEFF_HOME/snpEff.jar -c $SNPEFF_HOME/snpEff.config"
export SNPSIFT="-jar $SNPEFF_HOME/SnpSift.jar"

ref=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/Illumina_iGenome/Homo_sapiens/Ensembl/GRCh37/Sequence/BWAIndex/genome.fa

#region=$1; shift
output_prefix=$1; shift
input_bams="$@"
echo $input_bams

### CHOOSE CHROMOSOME
case $SGE_TASK_ID in
    23) region="X";;
    24) region="Y";;
    25) region="MT";;
    X) region="23";;
    Y) region="24";;
    MT) region="25";;
    *) region=$SGE_TASK_ID	
esac
echo $region


samtools mpileup \
    -d 2000 \
    -B \
    -q 1 \
    -l /ifs/scratch/c2b2/rr_lab/avp2106/CNV/cHL/SureSelect_Human_All_Exon_V5_S04380110_Regions_merged.bed \
    -r $region \
    -f $ref "$@" \
    | java -Xmx600m \
    -jar /ifs/scratch/c2b2/rr_lab/shares/VarScan/VarScan.v2.3.6.jar mpileup2cns \
    --output-vcf 1 \
    --strand-filter 0 \
    --min-var-freq 0.0000001 \
    --min-avg-qual 0 \
    --min-coverage 0 \
    | java -Xmx700m \
    -jar /ifs/scratch/c2b2/rr_lab/shares/snpEff-v3.3/SnpSift.jar extractFields - \
    "GEN[0].ABQ" "GEN[0].AD" "GEN[0].DP" \
    | awk '!/^#/ { print "1\t" $0 }' \
    > $output_prefix.$region.1p
