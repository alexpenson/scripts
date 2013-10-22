# Represents a list of intervals against a reference sequence that can
# be written to and read from a file. The file format is relatively
# simple and reflects the SAM alignment format to a degree. A SAM style
# header must be present in the file which lists the sequence records
# against which the intervals are described. After the header the file
# then contains records one per line in text format with the following
# values tab-separated: 
# - Sequence name
# - Start position (1-based)
# - End position (1-based, end inclusive)
# - Strand (either + or -)
# - Interval name (an, ideally unique, name for the interval)
#
# http://picard.sourceforge.net/javadoc/net/sf/picard/util/IntervalList.html

target_bed=$1; shift
sequence_dict=$1; shift
tail -n +3 $target_bed | awk 'BEGIN{OFS=FS="\t"} {print $1,$2,$3,"+",$4}' | cat $sequence_dict -
