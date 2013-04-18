#!/bin/awk -f
BEGIN{
    FS=OFS="\t"
}
{
    str=$2 "\t" $3;
    sub(/line/,"",$1);
    a[$1]=str
} 
END{
    sub(/line/,"",$1);
    max=$1;
#    print "max",max;
    for(i=1;i<=max*1;i++){
	if (i in a) {
	    print a[i]
	} else { 
	    print "" 
	} 
    }
}