#!/usr/bin/perl
use strict;

my $usage = "Use: $0 input.fastq\n";

if (scalar @ARGV != 1) { die $usage; }
if (! (open (IN, "<$ARGV[0]"))) { die "Can't open $ARGV[0]: $!\n"; }
if (-e "$ARGV[0].fasta") { die "$ARGV[0].fasta extists - please remove or rename\n"; }
if (-e "$ARGV[0].qual") { die "$ARGV[0].qual extists - please remove or rename\n"; }
if (! (open (FASTA, ">$ARGV[0].fasta"))) { die "Can't write to $ARGV[0].fasta: $!\n"; }
if (! (open (QUAL, ">$ARGV[0].qual"))) { die "Can't write to $ARGV[0].qual: $!\n"; }

my $id = "";
my $seq = "";
my $qual = "";
my $line = <IN>;
if ($line !~ /\@/) { die "$ARGV[0] does not look like a FASTQ file (it should start with \@)\n"; }
while ($line =~ s/^\@//o) {
    chomp ($line);
    my $id = $line;
    $line = <IN>;
    while ($line !~ s/^\+//o) {
	chomp ($line);
	$seq .= $line;
	$line = <IN>; }
    chomp ($line);
    if (($line =~ /\S/o) && ($line ne $id)) { die "ID of $id not followed by same identifier for quality scores\n"; }
    $line = <IN>;
    while (length ($qual) < length ($seq)) {
	chomp ($line);
	$qual .= $line;
	$line = <IN>; }
    print FASTA ">$id\n$seq\n";
    print QUAL ">$id\n";
    my @a = split //o, $qual;
    foreach my $i (@a) {
	my $q = 10 * log (1 + 10 ** ((ord ($i) - 64) / 10)) / log (10);
	printf QUAL "%1.0f ", $q; }
    print QUAL "\n";
    $id = "";
    $seq = "";
    $qual = ""; 
}



# #!/usr/bin/env perl
# # Author: Lee Katz

# # Convert a fastq to a fasta/qual combo using BioPerl, with some Linux commands

# use Bio::Perl;
# use Data::Dumper;
# use strict;
# use warnings;
# use threads;
# use Thread::Queue;
# use Getopt::Long;

# my $settings={};

# $|=1;
# my %numSequences; # static for a subroutine

# exit(main());

# sub main{
#     die("Usage: $0 -i inputFastqFile [-n numCpus -q outputQualfile -f outputFastaFile]") if(@ARGV<1);

#     GetOptions($settings,('numCpus=s','input=s','qualOut=s','fastaOut=s'));

#     my $file=$$settings{input}||die("input parameter missing");
#     my $outfasta=$$settings{fastaOut}||"$file.fasta";
#     my $outqual=$$settings{qualOut}||"$file.qual";
#     my $numCpus=$$settings{numCpus}||1;

#     my @subfile=splitFastq($file,$numCpus);
#     for my $f(@subfile){
# 	threads->create(\&convert,$f,"$f.fasta","$f.qual");
#     }
#     $_->join for (threads->list);
#   # join the sub files together
#     joinFastqFiles(\@subfile,$file);

#     return 0;
# }

# sub convert{
#     my($file,$outfasta,$outqual)=@_;

#     my $numSequences=numSequences($file);
#     my $reportEvery=int($numSequences/100) || 1;
#     print "$numSequences sequences to convert in $file\n";

#     my $in=Bio::SeqIO->new(-file=>$file,-format=>"fastq-illumina");
#     my $seqOut=Bio::SeqIO->new(-file=>">$outfasta",-format=>"fasta");
#     my $qualOut=Bio::SeqIO->new(-file=>">$outqual",-format=>"qual");
#     my $seqCount=0;
#     my $percentDone=0;
#     while(my $seq=$in->next_seq){
# 	$seqOut->write_seq($seq);
# 	$qualOut->write_seq($seq);
# 	$seqCount++;
# 	if($seqCount%$reportEvery == 0){
# 	    $percentDone++;
# 	    print "$percentDone%..";
# 	}
#     }
#     print "Done with subfile $file.\n";
#     return 1;
# }

# sub joinFastqFiles{
#     my($subfile,$outfileBasename)=@_;
#     my($command,$subfasta,$subqual);

#     # fasta
#     $subfasta.="$_.fasta " for(@$subfile);
#     $command="cat $subfasta > $outfileBasename.fasta";
#     system($command);

#     # qual
#     $subqual.="$_.qual " for (@$subfile);
#     $command="cat $subqual > $outfileBasename.qual";
#     system($command);

#     return 1;
# } 

# sub splitFastq{
#     my($file,$numCpus)=@_;
#     my $prefix="FQ"; # for fastq
#     my $numSequences=numSequences($file);
#     my $numSequencesPerFile=int($numSequences/$numCpus);
#     my $numSequencesPerFileRemainder=$numSequences % $numCpus;
#     my $numLinesPerFile=$numSequencesPerFile*4; # four lines per read; this could become incorrect if there is a really long read (not currently likely)
#     system("rm -rf tmp;mkdir tmp;");
#     system("split -l $numLinesPerFile $file 'tmp/FQ'");

#     return glob("tmp/FQ*");
# } 

# # use Linux to find the number of sequences quickly, but cache the value because it is still a slow process
# # This should probably changed to c -l4 but I don't have time to test the change
# # TODO for anyone reading this: please change this method to wc -l divided by 4.
# sub numSequences{
#     my $file=shift;
#     return $numSequences{$file} if($numSequences{$file});
#     my $num=`grep -c '^\@' $file`;
#     chomp($num);
#     $numSequences{$file}=$num;
#     return $num;
# }

