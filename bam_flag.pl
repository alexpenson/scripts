#!/usr/bin/perl

use strict;
use warnings;

my $usage = "Usage: $0 <bam_flag>\n";
my $bam_flag = shift or die $usage;

my $binary = dec2bin($bam_flag);
$binary = reverse($binary);

#163 -> 10100011

my @desc = (
'The read is paired in sequencing',
'The read is mapped in a proper pair',
'The query sequence itself is unmapped',
'The mate is unmapped',
'strand of the query',
'strand of the mate',
'The read is the first read in a pair',
'The read is the second read in a pair',
'The alignment is not primery (a read having split hits may have multiple primary alignment records)',
'The read fails quality checks',
'The read is either a PCR duplicate or an optical duplicate',
    );

my $query_mapped = '0';
my $mate_mapped = '0';
my $proper_pair = '0';

print "$binary\n";

for (my $i=0; $i< length($binary); ++$i){
    my $flag = substr($binary,$i,1);
   #print "\$i = $i and \$flag = $flag\n";
    if ($i == 1){
	if ($flag == 1){
	    $proper_pair = '1';
	}
    }
    if ($i == 2){
	if ($flag == 0){
	    $query_mapped = '1';
	}
    }
    if ($i == 3){
	if ($flag == 0){
	    $mate_mapped = '1';
	}
    }
    if ($i == 4){
	next if $query_mapped == 0;
	if ($flag == 0){
	    print "The read is mapped on the forward strand\n";
	} else {
	    print "The read is mapped on the reverse strand\n";
	}
    } elsif ($i == 5){
	next if $mate_mapped == 0;
	next if $proper_pair == 0;
	if ($flag == 0){
	    print "The mate is mapped on the forward strand\n";
	} else {
	    print "The mate is mapped on the reverse strand\n";
	}
    } else {
	if ($flag == 1){
	    print "$desc[$i]\n";
	}
    }
}

exit(0);

#from The Perl Cookbook
sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}

__END__
