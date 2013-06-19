#!/usr/bin/perl

# a patch - combine consecutive 'deletion rows' into one. input file must be sorted by ref, sample, chr, pos
# to run, e.g., 
# cat report_filtered_1 | ${d}/format_del.pl > report_filtered

# -----------------------------------

# args 
# $ARGV[0] 
# $ARGV[1] 
# ...

# learning perl ! 

# \d [0-9] Any digit
# \D [^0-9] Any character not a digit
# \w [0-9a-zA-z_] Any "word character"
# \W [^0-9a-zA-z_] Any character not a word character
# \s [ \t\n\r\f] whitespace (space, tab, newline, carriage return, form feed)
# \S [^ \t\n\r\f] Any non-whitespace character

# *      Match 0 or more times
# +      Match 1 or more times
# ?      Match 1 or 0 times
# {n}    Match exactly n times
# {n,}   Match at least n times
# {n,m}  Match at least n but not more than m times

# input file format:
#0   case             
#1   tf               	
#2   tf_lower         	
#3   tf_upper         	
#4   nf               	
#5   nf_lower         	
#6   nf_upper         	
#7   tf-nf            	
#8   tf-nf_lower      	
#9   tf-nf_upper      	
#10  t_qual           	
#11  t_vardepth       	
#12  t_totdepth       	
#13  n_qual           	
#14  n_vardepth       	
#15  n_totdepth       	
#16  pos  
#17  ref                
#18  var                
#19  #exon              
#20  nsyn               
#21  #spl               
#22  typeSNP            
#23  #tot               
#24  chr:pos            
#25  ref/var            
#26  gene               
#27  CCDS               
#28  sense              
#29  exon_#             
#30  codon              
#31  AA                 
#32  ref                


# -----------------------------------

use strict;																		# this means local variables inside loops, stay local

# promoter
#open (WRITE0, ">".$ARGV[0]."/promoter");
# transcript exon
#open (WRITE1, ">".$ARGV[0]."/transcript_exon");
# coding exon
# open (WRITE2, ">".$ARGV[0]."/exon");
#open (WRITE3, ">".$ARGV[0]."/transcript_coding");

# FILE MUST BE SORTED BY SAMPLE CHR POS

# initialize - the "my" initializes and scopes the variable (hence these will be global in scope)

my $num=1;			# how many rows get mushed together
my $nr=0;			# number row

my $pos_strt;		# the start position of a variant
my $aa_strt;		# the start position of an aa
my $aa_pos;			# the end position of an aa for dels
my $aa_ref;			# the aa string for dels

my $prev_sample;	# prev sample
my $prev_pos=0;		# prev position
my $prev_ref;		# prev ref
my $prev_var="x";	# prev var - set this so the first if statement will be false
my $prev_chr;		# prev chr
my $prev_aa;		# prev aa

# some more cols
my $prev_c1;
my $prev_cod;
my $prev_c3;
my $prev_c4;

my $cur_sample; 
my $cur_pos;
my $cur_ref;
my $cur_var;
my $cur_chr;
my $cur_aa;

my $cur_c1;
my $cur_cod;
my $cur_c3;
my $cur_c4;	

my @cols;			# this array will hold various cols to be averaged

while (<STDIN>)	
{	
	$nr++;
 	chomp;		
 	
	my @row = split(/\t/);	# break row on tabs (it uses 0 based counting)

	# --- get info from current row ---
	$cur_sample = $row[0]; 
	$cur_ref = $row[17];
	$cur_var = $row[18];
	$cur_aa = $row[31];
	my $chrpos = $row[24];			# these have scope within the while loop only
	my @cp = split(/:/, $chrpos);
	$cur_chr = $cp[0];
	$cur_pos = $cp[1];
	$cur_cod = $row[30]; # codon
	
	$cur_c1 = join "\t", @row[19 .. 23]; # #exon nsyn #spl typeSNP #tot
	$cur_c3 = join "\t", @row[26 .. 29]; # gene CCDS sense exon_#
	$cur_c4 = join "\t", @row[32 .. $#row];	# the rest
	
	# if deletion
	if ($cur_sample eq $prev_sample && $cur_chr eq $prev_chr && $cur_var eq "-" && $prev_var eq "-" && $cur_pos==$prev_pos+1) 		
	{
		$num++;
		$prev_pos=$cur_pos;
		$prev_ref=$prev_ref.$cur_ref;
		
		$cur_aa =~ m/(\D*)(\d*)(\D*)/;
		if ($aa_pos!=$2)
		{
			$aa_pos=$2;
			$aa_ref=$aa_ref.$1
		}
		
		# accumulate cols to average
		for (my $j = 1; $j <= 15; $j++)
		{
			$cols[$j]=$cols[$j]+$row[$j];
		}
						
	}
	# else output prev line and reset values. the first row will automatically go into this block
	else 
	{
		if ($nr!=1) 
		{
			if ($num==1) # not a del
			{
				# print $num,"\t";
				print $prev_sample,"\t";				
				for (my $j = 1; $j <= 15; $j++)
				{
					print $cols[$j]."\t";
				}
				print $pos_strt,"\t",$prev_ref,"\t",$prev_var,"\t",$prev_c1,"\t",$prev_chr.":".$pos_strt."-".$prev_pos,"\t",$prev_ref."/".$prev_var,"\t",$prev_c3,"\t",$prev_cod,"\t",$prev_aa,"\t",$prev_c4,"\n";
			}
			else # a del
			{				
				# get ave
				for (my $j = 1; $j <= 15; $j++)
				{
					$cols[$j]=int(0.5+$cols[$j]/$num);
				}	
						
				# print $num,"\t";
				print $prev_sample,"\t";
				for (my $j = 1; $j <= 15; $j++)
				{
					print $cols[$j]."\t";
				}
				print $pos_strt,"\t",$prev_ref,"\t",$prev_var,"\t",$prev_c1,"\t",$prev_chr.":".$pos_strt."-".$prev_pos,"\t",$prev_ref."/".$prev_var,"\t",$prev_c3,"\t","del","\t",$aa_ref."(".$aa_strt."-".$aa_pos.")-","\t",$prev_c4,"\n";				
				#print $pos_strt,"\t",$prev_pos,"\t",$prev_ref,"\t",$prev_var,"\t",$prev_chr,"\t",$aa_ref."(".$aa_strt."-".$aa_pos.")-","\n";
			}
		} 
			
		$num=1;
		$prev_sample=$cur_sample;
		$pos_strt=$cur_pos;
		$cur_aa =~ m/(\D*)(\d*)(\D*)/;
		$aa_ref=$1;
		$aa_strt=$2;
		$aa_pos=$2;
		$prev_pos=$cur_pos;
		$prev_var=$cur_var;
		$prev_ref=$cur_ref;
		$prev_chr=$cur_chr;
		$prev_aa=$cur_aa;
		
		$prev_c1=$cur_c1;
		$prev_cod=$cur_cod;
		$prev_c3=$cur_c3;
		$prev_c4=$cur_c4;		
		
		for (my $j = 1; $j <= 15; $j++)
		{
			$cols[$j]=$row[$j];
		}		
				
	}	
	
}

# print once at the end b/c we're staggered
if ($num==1) # not a del
{
	# print $num,"\t";
	print $prev_sample,"\t";				
	for (my $j = 1; $j <= 15; $j++)
	{
		print $cols[$j]."\t";
	}
	print $pos_strt,"\t",$prev_ref,"\t",$prev_var,"\t",$prev_c1,"\t",$prev_chr.":".$pos_strt."-".$prev_pos,"\t",$prev_ref."/".$prev_var,"\t",$prev_c3,"\t",$prev_cod,"\t",$prev_aa,"\t",$prev_c4,"\n";
}
else # a del
{				
	# get ave
	for (my $j = 1; $j <= 15; $j++)
	{
		$cols[$j]=int(0.5+$cols[$j]/$num);
	}	
						
	# print $num,"\t";
	print $prev_sample,"\t";
	for (my $j = 1; $j <= 15; $j++)
	{
		print $cols[$j]."\t";
	}
	print $pos_strt,"\t",$prev_ref,"\t",$prev_var,"\t",$prev_c1,"\t",$prev_chr.":".$pos_strt."-".$prev_pos,"\t",$prev_ref."/".$prev_var,"\t",$prev_c3,"\t","del","\t",$aa_ref."(".$aa_strt."-".$aa_pos.")-","\t",$prev_c4,"\n";				
}

