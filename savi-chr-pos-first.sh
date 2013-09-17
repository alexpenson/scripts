#!/bin/awk -f
BEGIN{
    OFS=FS="\t"
} 
{ 
    split($25,chrpos,":"); 
    split(chrpos[2],pos,"-"); 
    print chrpos[1],pos[1],pos[2],$0
}