#!/usr/bin/env Rscript
samtools_range <- function(x){
  paste0(x[1], ":", as.integer(x[2]), "-", as.integer(x[3]))
}
suppressPackageStartupMessages(suppressWarnings(library(biomaRt)))
args <- commandArgs(trailingOnly=TRUE)
ensembl <- useMart(biomart="ensembl", dataset="hsapiens_gene_ensembl")
ranges <- apply(
  getBM(mart=ensembl, 
        attributes=c('chromosome_name',
                     'start_position',
                     'end_position'), 
        filters='hgnc_symbol', 
        values=args),
  1,
  samtools_range
)
cat(ranges, sep="\n")
