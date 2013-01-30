#!/bin/env Rscript

library(xlsx)
library(ShortRead)

report <- read.xlsx(file("stdin"),1)
row.names(report) <- report$qseqid

stringset <- DNAStringSet(report$qseq)
names(stringset) <- report$sseqid

writeXStringSet(stringset, file=stdout())
