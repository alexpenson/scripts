#!/bin/awk -f
## http://awkology.wordpress.com/2010/02/08/mutate-dna/
BEGIN{
    srand();
    #srand(0); #reproducible
    ORS="";
}
{
    if (NR%4!=2) print $0"\n" #for reading fastq
    else {
	split(toupper($1),dna,"") #to upper case
	for(i in dna) {
	    r=int((rand()*4)+1)
	    ## mutate a fraction of bases
	    # f=int((rand()*10)+1)
            # i=i+f
	    split("AGTC",nt,"")
	    dna[i]=nt[r]
	    print dna[i]
	}
	print "\n"
    }
}