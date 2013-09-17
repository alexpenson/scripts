#!/usr/bin/env perl
### Converts SAVI report to CRAVAT format.
### Assumes that deletions have been merged
### such that chr:pos looks like chr1:100000-100000

use warnings;
use strict;
my $i = 1;
while (<>) {
    chomp;
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

    # $sense =~ s/"//g;
    # my $sense1 = (split ",", $sense)[0];
    # $sense1 =~ tr/10/+-/;
    my $sense1 = "+";

    die "chr:pos $chr_pos must look like chr1:100000-100000"
	unless ( $chr_pos =~ /(\w+):(\d+)-(\d+)/);
    print join "\t", ($i++, $1, $2-1, $3, $sense1, $ref, $var, $case), "\n";
}
