#!/bin/awk -f
BEGIN
{
    OFS=FS="\t"
} 
{ 
    split($25,chrpos,":"); 
    print chrpos[1],chrpos[2],$0
}