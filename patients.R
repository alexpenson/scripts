#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
if(length(args) != 3) {
  stop("Must provide two bgzip-tabixed vcfs, annotated with dbSnp in ID field, followed by an output prefix")
}
print(args)

library('VariantAnnotation')

file <- args[[1]]
patientID <- gsub(".dbSnp.vcf.gz","",file)

#############################################
### READ VCF
vcf <- readVcf(
  TabixFile(file),
  "hg19",
  ScanVcfParam(
    info=NA,
    geno=c("FREQ","DP")
    )
  )

#############################################
### extract allele frequencies for dbSnps
### where depth in all samples is greater than 10

### assumes 5 samples!!

freq <- geno(vcf)[["FREQ"]][grepl("rs",rownames(vcf)) & apply(geno(vcf)[["DP"]]>10,1, sum, na.rm=T)==5,]
colnames(freq) <- paste0(patientID, c("b","n1","n2","t1","t2"))

#############################################
file <- args[[2]]
patientID <- gsub(".dbSnp.vcf.gz","",file)

vcf <- readVcf(
  TabixFile(file),
  "hg19",
  ScanVcfParam(
    info=NA,
    geno=c("FREQ","DP")
    )
)

freq2 <- geno(vcf)[["FREQ"]][grepl("rs",rownames(vcf)) & apply(geno(vcf)[["DP"]]>10,1, sum, na.rm=T)==5,]
colnames(freq2) <- paste0(patientID, c("b","n1","n2","t1","t2"))

rm(vcf)

#############################################
### MERGE ALLELE FREQUENCY MATRICES
freqm <- merge(freq,freq2,by="row.names",all.x=T)
row.names(freqm) <- freqm$Row.names
freqm$Row.names <- NULL
freqm[is.na(freqm)] <- 0

#############################################
### HIERARCHICAL CLUSTERING
hc = hclust(as.dist(1-cor(freqm)))

output_prefix <- args[[3]]
write.table(cor(freqm), file=paste0(output_prefix,".txt"), sep="\t", quote=F)
pdf(paste0(output_prefix,".pdf"))
plot(hc, hang=-1)
dev.off()
