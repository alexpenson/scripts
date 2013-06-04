#!/usr/bin/env perl
#############################################
# Calculates allele frequency 
# based on nucleotide counts in 
# tab-delimited file assumed to come from 
# strelka SNV output and SnpSift extractFields
# (http://snpeff.sourceforge.net)
# Inserts columns AFTER the GEN[0].DP and GEN[1].DP fields.
# Uses stdin/stdout.
#############################################

use strict; 
use warnings;
#use Data::Dumper;
use List::Util qw(first);
use Math::Round;

my @input_field_names = ();
my %hash = ();
#my ($normal_depth_index, $tumor_depth_index);
my @nt = ("A","C","G","T");
while (<>) {
    if ($. == 1) { 
	### READ COLUMN NAMES
	@input_field_names = split(/\t/); 

	### WRITE COLUMN NAMES (WITH NEW ONES INSERTED)
	print join("\t", insert_normal_tumor_columns(\@input_field_names, \@input_field_names, 'GEN[0].ALTFREQ', 'GEN[1].ALTFREQ'));
	next;
    }

    ### READ FIELDS
    my @input_fields = split(/\t/);
    @hash{@input_field_names} = split(/\t/);

    my $ref = $hash{'REF'};
    my $alt = $hash{'ALT'};
    my $normal_depth = $hash{'GEN[0].DP'};
    my $tumor_depth = $hash{'GEN[1].DP'};
    my %normal = ();
    my %tumor = ();

###
#     print "ref\t";
#     print "$ref\t";
#     print "alt\t";
#     print "$alt\t";
#     print "normal_depth\t";
#     print "$normal_depth\t";
#     print "tumor_depth\t";
#     print "$tumor_depth\t";

    foreach (@nt) {
	$normal{$_} = $hash{'GEN[0].'.$_.'U[0]'};
	$tumor{$_} = $hash{'GEN[1].'.$_.'U[0]'};
    }

###
#     print $normal{$alt}, "\t";
#     print $tumor{$alt}, "\t";
#     print "\n";

     ### CALCULATE ALLELE FREQUENCIES
     my $normal_alt_freq = $normal_depth ? $normal{$alt} / $normal_depth : "-";
#     my $normal_ref_freq = $normal_depth ? $normal{$ref} / $normal_depth : "-";
     my $tumor_alt_freq = $tumor_depth ? $tumor{$alt} / $tumor_depth : "-";
#     my $tumor_ref_freq = $tumor_depth ? $tumor{$ref} / $tumor_depth : "-";

###
#     print $normal_alt_freq, "\n";
#     print nearest(0.001, $normal_alt_freq), "\n";

    print join("\t", insert_normal_tumor_columns(
		   \@input_field_names, 
		   \@input_fields, 
		   nearest( 0.001, $normal_alt_freq ) , 
		   nearest( 0.001, $tumor_alt_freq ) 
	       )
	);
    #exit ### one line only
}

sub insert_normal_tumor_columns {
    ### this function inserts entries into each line taken from the input file
    ### an entry for normal and tumor are are inserted AFTER columns named:
    ### DO NOT modify the input arrays
    my $normal_column_name = 'GEN[0].DP';
    my $tumor_column_name = 'GEN[1].DP';

    my ($input_field_names) = shift; ### from first line (header) of the input file
    my ($input_fields) = shift;
    my $normal_field = shift;
    my $tumor_field = shift;

    my $normal_index = first { $input_field_names->[$_] eq $normal_column_name } 0..$#$input_field_names;
    my $tumor_index  = first { $input_field_names->[$_] eq $tumor_column_name  } 0..$#$input_field_names;
    my @output_fields = @$input_fields;
    splice ( @output_fields, $normal_index+1, 0, $normal_field );
    splice ( @output_fields, $tumor_index+1,  0, $tumor_field  );
    return @output_fields;
}
