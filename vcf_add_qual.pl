#!/usr/bin/env perl
use strict; 
use warnings;
use Vcf;
use Data::Dumper;
use IPC::Open3;

my $vcf_filename = shift;
my %prior;
$prior{"b"} = shift;
$prior{"n1"} = shift;
$prior{"n2"} = shift;
$prior{"t1"} = shift;
$prior{"t2"} = shift;

my @tumor_normal_pairs = (
    [ "t1", "b" ],
    [ "t1", "n1" ],
    [ "t1", "n2" ],
    [ "t2", "b" ],
    [ "t2", "n1" ],
    [ "t2", "n2" ],
    );

my $vcf = Vcf->new(file=>$vcf_filename);

$vcf->parse_header();
foreach my $row (@tumor_normal_pairs) { 
    my ($tumor, $normal) = @$row;
    my $quality_score_name = "SAVI_" . $tumor . "_" . $normal;
    $vcf->add_header_line({key=>'INFO', ID=>$quality_score_name,Number=>1,Type=>'Integer',Description=>"P-value that $tumor and $normal are different as calculated by SAVI"});
}
print $vcf->format_header();
    
while (my $x = $vcf->next_data_hash()) {
    foreach my $row (@tumor_normal_pairs) { 
	my ($tumor, $normal) = @$row;
	my $quality_score_name = "SAVI_" . $tumor . "_" . $normal;
	my @tumor_normal_1p = ($$x{gtypes}{$tumor}{ABQ},
			       $$x{gtypes}{$tumor}{AD},
			       $$x{gtypes}{$tumor}{SDP},
			       $$x{gtypes}{$normal}{ABQ},
			       $$x{gtypes}{$normal}{AD},
			       $$x{gtypes}{$normal}{SDP}
	    );
	foreach (@tumor_normal_1p) {
	    $_ = 0 if $_ eq ".";
	}

	my $string_1p = join "\t", ("1", @tumor_normal_1p);
#    print "$string_1p\n";
	#my $string_1p = join "\\t", (1,23,5,40,23,0,100), "\n";
	my $pval_string = `echo -e "$string_1p" | savi_poster -pd $prior{"$tumor"} $prior{"$normal"} | savi_comp 2 0`;
	chomp($pval_string);
	my (undef, $pval) = split(/\t/, $pval_string); ### extract p-value (second column)
	#print "$pval\t";
#	print "@tumor_normal_1p $pval\n";

### convert to a phred score
	my $phred = 999; 
	if ($pval > 0 ) { 
	    $phred = int( 0.5 + -10 * log($pval) / log(10));
	}; 
	#print "$phred\n";

	$$x{INFO}{$quality_score_name} = $phred;
    }
    print $vcf->format_line($x);
}
