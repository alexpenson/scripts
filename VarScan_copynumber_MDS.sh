ref=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/samtools_faidx/hg19.fa
patient=$1; shift
#region=$1; shift
bam_dir=/ifs/scratch/c2b2/rr_lab/shares/MDS_DATA/combined/Columbia-Naomi-Exome/bam
#output_prefix=$1; shift
#samtools mpileup -r $region -d 10000 -B -q 1 -f $ref $bam_dir/$patient-2.recal.bam $bam_dir/$patient-1.recal.bam | \
samtools mpileup -d 100000 -B -q 1 -f $ref $bam_dir/$patient-2.recal.bam $bam_dir/$patient-1.recal.bam | \
    awk '$4+$7>0' | \
    java -Xmx700m -jar /ifs/scratch/c2b2/rr_lab/shares/VarScan/VarScan.v2.3.6.jar copynumber - $patient --mpileup 1

java -Xmx700m -jar /ifs/scratch/c2b2/rr_lab/shares/VarScan/VarScan.v2.3.6.jar copyCaller $patient.copynumber --output-file $patient.copynumber.called

#    > $output_prefix.$region.vcf
