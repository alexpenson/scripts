#!/usr/bin/env Rscript
suppressPackageStartupMessages(require(ShortRead))
seqlength <- 100
nseq <- 1000
mydict <- DNAStringSet(sapply(1:nseq, function(x) paste(sample(c("A","T","G","C"), seqlength, replace=T), collapse=""))) # Creates random sample sequences.
names(mydict) <- 1:nseq
writeXStringSet(mydict, file="random.fasta")
