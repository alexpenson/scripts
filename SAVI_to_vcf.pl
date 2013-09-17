#!/usr/bin/env perl
### Converts SAVI report to VCF format.

### samtools must be in your $PATH

### Assumes that deletions have been merged
### such that chr:pos looks like chr1:100000-100000

### Indels are left-aligned to fit the VCF format:
### One reference base to the left of each indel is part of both REF and ALT alleles

use warnings;
use strict;
#use Bio::DB::Fasta;
use Getopt::Long;
#Getopt::Long::Configure(qw{no_auto_abbrev no_ignore_case_always});

my $reference="";
GetOptions ('f=s' => \$reference); # genome reference: faidx-indexed fasta
#print "$reference\n";
die "Usage: $0 -f genome.fa" unless length $reference;

my $header = <<EOF;
##fileformat=VCFv4.1
##source=SAVI
##INFO=<ID=SAMPLE,Number=1,Type=String,Description="Name of Sample eg. patient identifier">
##INFO=<ID=GENE,Number=1,Type=String,Description="Name of gene">
##INFO=<ID=AA,Number=1,Type=String,Description="Amino acid change">
##FORMAT=<ID=ABQ,Number=1,Type=Integer,Description="Average quality of variant-supporting bases">
##FORMAT=<ID=AD,Number=1,Type=Integer,Description="Depth of variant-supporting reads">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Total Read Depth">
##FORMAT=<ID=FREQ,Number=1,Type=Integer,Description="Percentage of variant-supporting reads">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	tumor	normal
EOF

print $header;

while (<STDIN>) {
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
### LEFT-ALIGN INDELS

    #############################################
    ### INSERTIONS
    if ($ref eq "-") {
	my $ref_from_fasta = reference($chr_pos);
	$ref = $ref_from_fasta;
	$var = $ref_from_fasta . $var;
    }
    #############################################
    ### DELETIONS
    elsif ($var eq "-") {
	$pos -= 1;
	$chr_pos = "$chr:$pos-$pos";
	my $ref_from_fasta = reference($chr_pos);
	$ref = $ref_from_fasta . $ref;
	$var = $ref_from_fasta;
    }


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
    my $FORMAT = join ":", ("ABQ", "AD", "DP", "FREQ");
    my $tumor = join ":", ($t_qual, $t_vardepth, $t_totdepth, $tf);
    my $normal = join ":", ($n_qual, $n_vardepth, $n_totdepth, $nf);

#############################################
### WRITE VCF
    print join "\t", ($CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO, $FORMAT, $tumor, $normal), "\n";
}

sub reference {
    my $chr_pos = shift;
    my $cmd = "samtools faidx $reference $chr_pos |";
    open(SAMTOOLS, $cmd);
    my @lines = <SAMTOOLS>;
    chomp(my $ref_from_fasta = $lines[1]);
#    print($ref_from_fasta . "\t" . $ref . "\n");
    close(SAMTOOLS);
    return uc($ref_from_fasta);
    
}
