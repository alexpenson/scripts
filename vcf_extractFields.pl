#!/usr/bin/env perl
use strict; 
use warnings;
use Vcf;
use Data::Dumper;
use File::Basename;
use Getopt::Long;

#############################################
### NON SYNONYMOUS ONLY, BY DEFAULT
my $inc_syn = 0;
GetOptions ('inc_syn' => \$inc_syn );

my @samples = ("b", "n1", "n2", "t1", "t2");

#############################################
### PRINT HEADER LINE
my @cols = ("SAMPLE", "CHROM", "POS", "ID", "REF", "ALT",
	    "b_FREQ", "b_DP", "b_AFF", "b_GQ",
	    "n1_FREQ", "n1_DP", "n1_AFF", "n1_GQ", 
	    "n2_FREQ", "n2_DP", "n2_AFF", "n2_GQ",
	    "normal_FREQ", "normal_DP",
	    "t1_FREQ", "t1_DP", "t1_AFF", "t1_QUAL",
	    "t2_FREQ", "t2_DP", "t2_AFF", "t2_QUAL", 
	    "tumor_FREQ", "tumor_DP", "tumor_QUAL",
	    "EFFECT", "IMPACT", "FUNCLASS", "CODON", "AA", "AA_LEN", "GENE", "BIOTYPE", "CODING", "TRID", "EXON_RANK",
	    "dbSNPBuildID", "COSMIC_NSAMP", "N_PATIENTS_NORMAL");
print "#", join("\t", @cols), "\n";

#############################################
### DEFINE COLUMN VARIABLES
my %fields;

#############################################
### LOOP OVER INPUT FILES
foreach my $vcf_filename (@ARGV) {
    my $vcf = Vcf->new(file=>$vcf_filename, version => '4.1', silent => 'true');
    $vcf->parse_header(silent => 'true');
    my @samples_in_file = $vcf->get_samples();

#############################################
### FILENAME UP TO THE FIRST . IS TAKEN 
### AS THE PATIENT NAME
    my $patient = (split /\./, basename($vcf_filename))[0];
    
#############################################
### PARSE LINES 
### VARIANTS WITH HIGH OR MODERATE EFFECT ONLY
### (UNLESS inc_syn OPTION IS SET)
    while (my $line = $vcf->next_line()) {
	my $variant_impact;
	if ( $line =~ /HIGH/ ) {
	    $variant_impact = "HIGH";
	} elsif ( $line =~ /MODERATE/ ) { 
	    $variant_impact = "MODERATE";
	} elsif ( $line =~ /LOW/ && $inc_syn ) { 
	    $variant_impact = "LOW";
	} elsif ( $line =~ /MODIFIER/ && $inc_syn ) { 
	    $variant_impact = "MODIFIER";
	} else {
	    next;
	}
	my $x = $vcf->next_data_hash($line);
	map { $fields{$_} = "" } @cols;

	### DEBUG
	# print Dumper($x);
	# last;

#############################################
### EXTRACT FIELDS
	$fields{SAMPLE} = $patient;
	$fields{CHROM} = $$x{CHROM};
	$fields{POS} = $$x{POS};
	$fields{ID} = $$x{ID};
	$fields{REF} = $$x{REF};
	$fields{ALT} = $$x{ALT}[0]; ### choose the primary alternate allele

	foreach my $sample (@samples_in_file) {
	    if ($$x{gtypes}{$sample}{PVAL} eq ".") { $$x{gtypes}{$sample}{PVAL} = 1 }; 
	    if ($$x{gtypes}{$sample}{DP} eq ".") { $$x{gtypes}{$sample}{DP} = 0 }; 
	    if ($$x{gtypes}{$sample}{FREQ} eq ".") { $$x{gtypes}{$sample}{FREQ} = 0 }; 
	    if ($$x{gtypes}{$sample}{AD} eq ".") { $$x{gtypes}{$sample}{AD} = 0 }; 
	    if ($$x{gtypes}{$sample}{ADF} eq ".") { $$x{gtypes}{$sample}{ADF} = 0 }; 
	    
	    $fields{$sample."_FREQ"} = $$x{gtypes}{$sample}{FREQ};
	    $fields{$sample."_DP"} = $$x{gtypes}{$sample}{DP};
	    if (grep {$_ eq $sample} ("b","n1","n2")) {
		$fields{$sample."_GQ"} = $$x{gtypes}{$sample}{GQ};
	    } else {
		$fields{$sample."_QUAL"} = -10 * log( $$x{gtypes}{$sample}{PVAL} ) / log(10);	       
	    }
	    $fields{$sample."_AFF"} = 0;
	    if ($$x{gtypes}{$sample}{AD} > 0) {
		$fields{$sample."_AFF"} = 100 * $$x{gtypes}{$sample}{ADF} / $$x{gtypes}{$sample}{AD};
		$fields{$sample."_AFF"} = sprintf("%.1f", $fields{$sample."_AFF"});
	    }
	}

#############################################
### POOLED WGA TUMOR/NORMAL SAMPLES
	$fields{normal_DP} = $$x{gtypes}{n1}{DP} + $$x{gtypes}{n2}{DP};
	$fields{normal_FREQ} = 0;
	if ($fields{normal_DP} != 0) {
	    $fields{normal_FREQ} = ($$x{gtypes}{n1}{FREQ} * $$x{gtypes}{n1}{DP} + $$x{gtypes}{n2}{FREQ} * $$x{gtypes}{n2}{DP}) / $fields{normal_DP};
	    $fields{normal_FREQ} = sprintf("%.2f",$fields{normal_FREQ})
	}
	$fields{tumor_DP} = $$x{gtypes}{t1}{DP} + $$x{gtypes}{t2}{DP};
	$fields{tumor_FREQ} = 0;
	if ($fields{tumor_DP} != 0) {
	    $fields{tumor_FREQ} = ($$x{gtypes}{t1}{FREQ} * $$x{gtypes}{t1}{DP} + $$x{gtypes}{t2}{FREQ} * $$x{gtypes}{t2}{DP}) / $fields{tumor_DP};
	    $fields{tumor_FREQ} = sprintf("%.2f",$fields{tumor_FREQ})
	}
	$fields{tumor_QUAL} = $fields{t1_QUAL} + $fields{t2_QUAL};
	$fields{t1_QUAL} = sprintf("%.1f", $fields{t1_QUAL});
	$fields{t2_QUAL} = sprintf("%.1f", $fields{t2_QUAL});
	$fields{tumor_QUAL} = sprintf("%.1f", $fields{tumor_QUAL});

#############################################
### PARSE THE snpEff EFF FIELD
	my @effs = split( /,/, $$x{INFO}{EFF});
	foreach my $eff (@effs) {
	    if ($eff =~ /(\w+)\((.*)\)/) {
		$fields{"EFFECT"} = $1;
		### assume no $ERRORS, $WARNINGS
		@fields{("IMPACT", "FUNCLASS", "CODON", "AA", "AA_LEN", "GENE", "BIOTYPE", "CODING", "TRID", "EXON_RANK")}
		= split(/\|/, $2);
### SELECT THE FIRST HIGH OR ELSE THE FIRST MODERATE
### DO NOT PARSE FURTHER THAN NECESSARY
		if ($fields{IMPACT} eq $variant_impact) { last }
	    }
	}

#############################################
### REMAINING INFO FIELDS
	$fields{dbSNPBuildID} = $$x{INFO}{dbSNPBuildID};
	$fields{COSMIC_NSAMP} = $$x{INFO}{COSMIC_NSAMP};
	$fields{N_PATIENTS_NORMAL} = $$x{INFO}{N};

#############################################
### PRINT ALL FIELDS	
	$fields{$_} //= "" for @cols;
	print join("\t", @fields{@cols}), "\n";
    }
}

exit;
