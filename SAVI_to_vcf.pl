#!/usr/bin/env perl
### Converts SAVI report to CRAVAT format.
### Assumes that deletions have been merged
### such that chr:pos looks like chr1:100000-100000

use warnings;
use strict;

my $header = <<EOF;
##fileformat=VCFv4.1
##source=SAVI
##INFO=<ID=SAMPLE,Number=1,Type=String,Description="Name of Sample eg. patient identifier">
##INFO=<ID=GENE,Number=1,Type=String,Description="Name of gene">
##INFO=<ID=AA,Number=1,Type=String,Description="Amino acid change">
##FORMAT=<ID=ABQ,Number=1,Type=Integer,Description="Average quality of variant-supporting bases">
##FORMAT=<ID=AD,Number=1,Type=Integer,Description="Depth of variant-supporting reads">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Total Read Depth">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	tumor	normal
EOF

print $header;

while (<>) {
    chomp;

#############################################
### PARSE SAVI
    next if (/^case/);
    my($case, 
       $tf, $tf_lower, $tf_upper, 
       $nf, $nf_lower, $nf_upper, 
       $tf_nf, $tf_nf_lower, $tf_nf_upper, 
       $t_qual, $t_vardepth, $t_totdepth, 
       $n_qual, $n_vardepth, $n_totdepth, 
       $pos, $ref, $var, 
       $Nexon, $nsyn, $Nspl, $typeSNP, $Ntot, 
       $chr_pos, $ref_var, 
       $gene, $CCDS, $sense, $exon_N, $codon, $AA) = split "\t";

    my ( $chr, undef , undef ) = split(/:|-/, $chr_pos);


#############################################
### SAVI to VCF
    my $CHROM = $chr;
    my $POS = $pos;
    my $ID = ".";
    my $REF = $ref;
    my $ALT = $var;
    my $QUAL = ".";
    my $FILTER = ".";
    my $INFO = "SAMPLE=$case;GENE=$gene;AA=$AA";
    my $FORMAT = join ":", ("ABQ", "AD","DP");
    my $tumor = join ":", ($t_qual, $t_vardepth, $t_totdepth);
    my $normal = join ":", ($n_qual, $n_vardepth, $n_totdepth);

#############################################
### WRITE VCF
    print join "\t", ($CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $tumor, $normal), "\n";
}
