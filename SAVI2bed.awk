#!/bin/awk -f
## create a bed files containing all the variants in a SAVI report
## one file per case
## assumes that deletions have been merged: chr1:10000-10000
BEGIN{
    FS=OFS="\t"
} 
!/^case/ 
{
    split($25,a,":");
    split(a[2],b,"-");
    filename = $1 ".bed";
    print a[1],b[1],b[2] >> filename
}