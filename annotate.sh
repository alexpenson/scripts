chr=$1


# set the genome build:
hg=hg19;

# hardwire paths to ref:
ref=/ifs/scratch/c2b2/rr_lab/shares/ref/${hg}
refchr=${ref}/results/chr
ccds=${refchr}/${chr}/ccds
snp=${refchr}/${chr}/snp
thousand=${refchr}/${chr}/1000genome
d1=/ifs/home/c2b2/rr_lab/shares/scripts

varsfile=tmp_0

cut -f3- > $varsfile

cat $varsfile | cut -f1-3 | awk '{print int($1)"\t"int($1)"\t"100"\t"NR"\t"$2"\t"$3}' > tmp_1

sort -k1,1n -k2,2n -m tmp_1 ${ccds}/seg_exon | $d1/segsmerge | $d1/segsone 100 > tmp_2

#rm tmp_1

cat tmp_2 | $d1/modannotate -t /ifs/home/c2b2/rr_lab/shares/scripts/humangencode.txt /ifs/scratch/c2b2/rr_lab/shares/ref/${hg}/results/chr/${chr}/ccds/seq -c ${chr} -transcript /ifs/scratch/c2b2/rr_lab/shares/ref/${hg}/results/chr/${chr}/ccds/name_transcript -ccds /ifs/scratch/c2b2/rr_lab/shares/ref/${hg}/results/chr/${chr}/ccds/name -exon > tmp_3

paste tmp_0 tmp_3