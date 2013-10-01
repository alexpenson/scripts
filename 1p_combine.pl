#!/usr/bin/env perl
use warnings; 
use strict;
use List::Util qw(sum);

#############################################
# READS PASTED 1p FILES

# 1p files have four tab-delimited columns:
# 1) 1
# 2) average quality of variant-supporting reads (q)
# 3) number of variant-supporting reads (v)
# 4) total depth (d)
#
# 1   q    v   d
# eg.
# 1   23   4   10
# 1   40   1   20
# 1   0    0   15

while (<>) {
    chomp; 
    my @F=split(/\t/, $_, -1); 
    $_ ||= 0 for @F;
    my $i=0;
    my @q = grep {++$i % 4 == 2} @F;
    my @v = grep {++$i % 4 == 3} @F;
    my @d = grep {++$i % 4 == 0} @F;

### combined depths are the sum of the inputs
    my $v_combined = sum(@v);
    my $d_combined = sum(@d);
### combined average quality is the mean of the inputs, weighted by the variant depth, v
    my $q_combined = 0;
    if ($v_combined > 0 ) {	
	$q_combined = sum( map { $q[$_] * $v[$_] } 0..$#q );
	$q_combined /= $v_combined;
	$q_combined = int($q_combined + 0.5);
    }
    
    print join "\t", ("1", $q_combined,  $v_combined, $d_combined), "\n";
}
    
