#!/bin/env Rscript

## INPUT
d <- read.table(file("stdin"), header=TRUE, row.names=NULL)

## LOAD NORMAL FILE AS MATRIX
normal <- read.table('/ifs/scratch/c2b2/rr_lab/avp2106/Cancer/AllNormals/AllNormals.sorted.key', c(0))
avec <- normal[,1]

## BUILD KEY (POS + 1)
ref.var2 <- function (x) as.character(x[26])
d$ref.var2 <- apply(d,1,ref.var2)

pos2 <- function (x) as.integer(unlist(strsplit(as.character(x[25]),split="[-:]"))[2])
d$pos2 <- apply(d,1,pos2)

chr <- function (x) unlist(strsplit(as.character(x[25]),split="[-:]"))[1]
d$chr <- apply(d,1,chr)

d$key <- paste(d$chr, ":", d$pos2, "_", d$ref.var2, sep="")

write(head(d$key), stderr())

## CREATE NORMAL COLUMN
d$normal <- d$key %in% avec

d$key <- NULL
d$ref.var2 <- NULL
d$chr <- NULL
d$pos2 <- NULL

write.table(d,file=stdout(),row.names=FALSE, quote=FALSE, sep="\t")
#write.table(d,file=outputfilename,row.names=FALSE, quote=FALSE, sep="\t")