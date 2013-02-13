#!/usr/bin/env Rscript
# Creates random FASTA file
suppressPackageStartupMessages(library(Biostrings))
seqlength <- 100
nseq <- 1000
mydict <- DNAStringSet(sapply(1:nseq, function(x) paste(sample(c("A","T","G","C"), seqlength, replace=T), collapse=""))) 
names(mydict) <- 1:nseq
writeXStringSet(mydict, file="random.fasta")