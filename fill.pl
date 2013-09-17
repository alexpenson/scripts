#!/usr/bin/env perl
### for a tab delimited file with a header
### this script add tabs 
### at the end of the line to match the header
### especially useful with UNIX paste for example.
use strict; 
use warnings;
#use Data::Dumper;

my @input_field_names = ();
my %hash = ();
while (<>) { 
    chomp;
    if ($. == 1) { 
	### READ COLUMN NAMES
	@input_field_names = split(/\t/, $_, -1); 
	print "$_\n";
	next;
    }

    ## -1 tells split to include empty fields at end of line    
    @hash{@input_field_names} = split(/\t/, $_, -1); 
    print join("\t", @hash{@input_field_names}), "\n";
}
