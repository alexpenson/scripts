#!/usr/bin/env Rscript
m <- read.table('master.inc_mod.dbSnp.UNAFFECTED_INDIVIDUALS.tumor_QUAL_60.txt', comment.char="", sep="\t", header=T, fill=T)
names(m)[1] <- "patient"
m <- transform(m, patient = sprintf('P%s', patient)) 
names(m)[names(m)=="EFFECT"] <- "SNPEFF_EFFECT"
names(m)[names(m)=="GENE"] <- "gene"

### calculate categ
#m$categ <- 1
names(m)[names(m)=="CHROM"] <- "chr"
names(m)[names(m)=="REF"] <- "Reference_Allele"
names(m)[names(m)=="ALT"] <- "Tumor_Seq_Allele1"
m$Tumor_Seq_Allele2 <- m$Tumor_Seq_Allele1
#m$effect <- ifelse(m$Variant_Classification == "SYNONYMOUS_CODING", "silent", "nonsilent")

library(plyr)
m$effect <- revalue(
  factor(m$SNPEFF_EFFECT),  
  c("SYNONYMOUS_CODING"                  = "silent",
    "SYNONYMOUS_STOP"                    = "silent",
    "INTRAGENIC"                         = "noncoding",
    "INTRON"                             = "noncoding",
    "UTR_3_PRIME"                        = "noncoding",
    "UTR_5_PRIME"                        = "noncoding",
    "EXON"                               = "noncoding",
    "NON_SYNONYMOUS_CODING"              = "nonsilent",
    "FRAME_SHIFT"                        = "nonsilent",
    "STOP_GAINED"                        = "nonsilent",
    "CODON_CHANGE_PLUS_CODON_DELETION"   = "nonsilent",
    "CODON_DELETION"                     = "nonsilent",
    "SPLICE_SITE_ACCEPTOR"               = "nonsilent",
    "SPLICE_SITE_DONOR"                  = "nonsilent",
    "CODON_CHANGE_PLUS_CODON_INSERTION"  = "nonsilent",
    "CODON_INSERTION"                    = "nonsilent",
    "START_LOST"                         = "nonsilent",
    "NON_SYNONYMOUS_START"               = "nonsilent",
    "STOP_LOST"                          = "nonsilent")
  )

m$Variant_Classification <- revalue(
  factor(m$SNPEFF_EFFECT),  
  c("SYNONYMOUS_CODING"                  = "Silent",
    "SYNONYMOUS_STOP"                    = "Silent",
    "INTRAGENIC"                         = "Flank",
    "INTRON"                             = "Intron",
    "UTR_3_PRIME"                        = "3'UTR",
    "UTR_5_PRIME"                        = "3'UTR",
    "EXON"                               = "RNA",
    "NON_SYNONYMOUS_CODING"              = "Missense_Mutation",
    "FRAME_SHIFT"                        = "Frame_Shift_Del",
    "STOP_GAINED"                        = "Nonsense_Mutation",
    "CODON_CHANGE_PLUS_CODON_DELETION"   = "Frame_Shift_Ins",
    "CODON_DELETION"                     = "In_Frame_Del",
    "SPLICE_SITE_ACCEPTOR"               = "Splice_Site",
    "SPLICE_SITE_DONOR"                  = "Splice_Site",
    "CODON_CHANGE_PLUS_CODON_INSERTION"  = "Frame_Shift_Ins",
    "CODON_INSERTION"                    = "In_Frame_Ins",
    "NON_SYNONYMOUS_START"               = "Translation_Start_Site",
    "START_LOST"                         = "Translation_Start_Site",
    "STOP_LOST"                          = "Nonstop_Mutation" )
)

#m$Variant_Classification <- ifelse(m$FUNCLASS == "SILENT", "Silent", "")
#m$Variant_Classification <- ifelse(m$FUNCLASS == "MISSENSE", "Missense_Mutation", "")
#m$Variant_Classification <- ifelse(m$FUNCLASS == "", "Frame_Shift_Del", "")

#With [the reference genome] and the Variant_Classification, Reference_Allele, and Tumor_Seq_Allele1+2 columns, "categ" can be computed.

## nuc <- ""
## if ( length(m$REF) + length(m$ALT) > 2) {
##  m$categ <- "null+indel mutations"#
##} else {
##  if (m$REF == "A" || m$REF == "T") {
#   nuc <- "A:T"
#    
#  } else {
##     nuc <- "C:G"
##   }
## }


write.table(m, file='master.inc_mod.dbSnp.UNAFFECTED_INDIVIDUALS.tumor_QUAL_60.no_categ.txt', sep="\t", quote=F, row.names=F)

