#!/bin/env Rscript

## INPUT
d <- read.table(file("stdin"), header=TRUE, fill=TRUE)

## LOAD NORMAL FILE AS MATRIX
normal <- read.table('/ifs/scratch/c2b2/rr_lab/avp2106/Cancer/AllNormals/AllNormals.sorted.key', c(0))
avec <- normal[,1]

## BUILD KEY (POS + 1)
pos <- function (x) as.integer(unlist(strsplit(as.character(x[13]),split="[-:]"))[2])
d$pos <- apply(d,1,pos)

chr <- function (x) unlist(strsplit(as.character(x[13]),split="[-:]"))[1]
d$chr <- apply(d,1,chr)

d$key <- paste(d$chr, ":", d$pos, "_", d$ref.var, sep="")

## CREATE NORMAL COLUMN
d$normal <- d$key %in% avec

d$key <- NULL
d$chr <- NULL
d$pos <- NULL

write.table(d,file=stdout(),row.names=FALSE, quote=FALSE, sep="\t")
#write.table(d,file=outputfilename,row.names=FALSE, quote=FALSE, sep="\t")
