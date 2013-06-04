cat $1 | /ifs/home/c2b2/rr_lab/shares/scripts/fastq2fasta.awk | /nfs/apps/blasr/bin/blasr -sam -bestn 1 /ifs/scratch/c2b2/rr_lab/shares/ref/hg19/blasr/hg19.fa - 
