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

# my $header = <<EOF;
# ##fileformat=VCFv4.1
# ##source=SAVI
# ##INFO=<ID=ID,Number=1,Type=String,Description="disease|date|investigator|ID">
# ##INFO=<ID=GENE,Number=1,Type=String,Description="Name of gene">
# ##INFO=<ID=CCDS,Number=.,Type=String,Description="ID for each transcript from http://www.ncbi.nlm.nih.gov/CCDS">
# ##INFO=<ID=AA,Number=.,Type=String,Description="Amino acid change in each transcript">
# ##INFO=<ID=reference,Number=1,Type=String,Description="genome reference">
# ##INFO=<ID=NCosmicHits,Number=1,Type=String,Description="Number of records of the mutation in COSMIC">
# ##INFO=<ID=NMutPerID,Number=1,Type=String,Description="Number of mutation in the sample given by 'ID'">
# #CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
# EOF

my $header = <<EOF;
##fileformat=VCFv4.1
##source=meganormal
##INFO=<ID=MEGANORMAL_ID,Number=1,Type=String,Description="disease|date|investigator|ID">
##INFO=<ID=NMutPerID,Number=1,Type=String,Description="Number of mutations in the sample given by MEGANORMAL_ID">
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO
EOF

print $header;

while (<STDIN>) {
    chomp;

#############################################
### PARSE meganormal
    next if ($. == 1);
    my ($id, $chr_pos, $ref_var, $gene, $ccds, $AA, $reference, $NCosmicHits, $NMutPerID ) = split "\t";

    my ( $chr, $pos ) = split(/:/, $chr_pos); 
    my ( $ref, $var ) = split(/\//, $ref_var);

    $chr =~ s/^chr//;

#############################################
### LEFT-ALIGN INDELS

    #############################################
    ### INSERTIONS
    if ($ref eq "-") {
	$chr_pos = $chr.":".$pos."-".$pos;
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
    my $INFO = "MEGANORMAL_ID=$id;NMutPerID=$NMutPerID";

#############################################
### WRITE VCF
    print join "\t", ($CHROM, $POS, $ID, $REF, $ALT, $QUAL, $FILTER, $INFO), "\n";
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
