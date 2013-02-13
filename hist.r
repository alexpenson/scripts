#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
print(args)
if(length(args)) {
  filename <- args[[1]]
} else {
  filename <- "rplot.pdf"
}
print(filename)
d <- scan(file("stdin"), what=list(x=0), quiet=TRUE);
#print(d$x)
pdf(filename)
hist(d$x, main=filename)
dev.off()