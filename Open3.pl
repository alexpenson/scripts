#!/usr/bin/env perl
use strict;
use warnings;
use IPC::Open3;

#my $r = 0;
#my $pid = open3(\*CHLD_IN, \*CHLD_OUT, \*CHLD_ERR, "tr \'[a-z]\' \'[A-Z]\'")
my($wtr, $rdr, $err);
use Symbol 'gensym'; $err = gensym;
my $pid = open3($wtr, $rdr, $err, "/ifs/scratch/c2b2/rr_lab/avp2106/scripts/child.pl")
    or die "open3() failed $!";
print $wtr "Asdf\n";
$rdr = <CHLD_OUT>;
print "Got $rdr from child\n";
# close(CHLD_IN);
# close(CHLD_OUT);



