#$ -l mem=2G,time=8::
#$ -pe smp 8
ref=${2:-/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19}
/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.1.0/bowtie2 -p 8 -q -x $ref -U $1 --un ${1/.fq/.unmapped.fq} --local | samtools view -SbF4 - > ${1/.fq/.bam}
