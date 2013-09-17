#!/usr/bin/env Rscript
options(warn=-1)                                                        #2
sink("/dev/null")                                                       #3
input <- file("stdin", "r")                                             #4

suppressMessages(suppressWarnings(library(biomaRt)))
ensembl <- useMart("ensembl",dataset="hsapiens_gene_ensembl")

getGenes <- function(x) {
  getBM(attributes=c('hgnc_symbol'), 
        filters = c('chromosome_name','start','end'), 
        values = list(x[1],x[2],x[3]), 
        mart = ensembl)
}

geneString <- function(x){
  paste(getGenes(x),collapse=",")
  #############################################
  ### R > 3.0.0
#  paste(getGenes(x)$hgnc_symbol,collapse=",")
}

#############################################
### READ INPUT BED
while(length(currentLine <- 
             readLines(input, n=1, warn=FALSE)) > 0) {
  fields <- unlist(strsplit(currentLine, "\t")) 


  #############################################
  ### LOOK-UP GENE
  if (fields[1] == "chrom") {
    fields <- c(fields, "gene")
  } else {
    fields <- c(fields, geneString(fields))
  }
  
  #############################################
  ### PRINT
  sink() 
  cat(paste(fields, collapse="\t"), "\n") 
  sink("/dev/null") 
}
close(input)
