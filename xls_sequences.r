#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
inputfile <- args[1]
outputfile <- args[2]
write('args', stderr())

suppressPackageStartupMessages(require(xlsx))
suppressPackageStartupMessages(require(tools))
suppressPackageStartupMessages(require(ShortRead))
write('lib', stderr())

report <- read.xlsx(inputfile, 1)
row.names(report) <- report$qseqid
write('file', stderr())

subset <- report[report$taxid == 68887,]

stringset <- DNAStringSet(subset$qseq)
names(stringset) <- subset$sseqid

writeXStringSet(stringset, format=file_ext(outputfile), file=outputfile)

