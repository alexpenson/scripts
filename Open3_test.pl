#!/usr/bin/env perl
# Script to test IPC::Open3
# Runs, displays $pid to STDOUT, but opened
# files are empty.
# http://www.perlmonks.org/?node_id=150748


use strict;
use warnings;
use diagnostics;
use IPC::Open3;
use IO::Select; # for select
use Symbol; # for gensym

$|++;

my $cmd = "./child.pl";

open(ERRLOG, ">error.log") or die "Can't open error log! $!";
open(OUTPUT, ">output.log") or die "Can't open output log! $!";

my ($infh,$outfh,$errfh); # these are the FHs for our child 
$errfh = gensym(); # we create a symbol for the errfh 
                   # because open3 will not do that for us 

my $pid;

eval{
    $pid = open3($infh, $outfh, $errfh, $cmd);
    print $infh "IN";
};
die "open3: $@\n" if $@;

print "PID was $pid\n";

my $sel = new IO::Select; # create a select object to notify
                          # us on reads on our FHs
$sel->add($outfh,$errfh); # add the FHs we're interested in

while(my @ready = $sel->can_read) { # read ready
    foreach my $fh (@ready) { 
        my $line = <$fh>; # read one line from this fh
        if(not defined $line){ # EOF on this FH
            $sel->remove($fh); # remove it from the list
            next;              # and go handle the next FH
        }
        if($fh == $outfh) {     # if we read from the outfh
            print OUTPUT $line; # print it to OUTFH
        } elsif($fh == $errfh) {# do the same for errfh  
            print ERRLOG $line;
        } else { # we read from something else?!?!
            die "Shouldn't be here\n";
        }
    }
}

close(ERRLOG) or die "Can't close filehandle! $!";
close(OUTPUT) or die "Can't close filehandle! $!";

