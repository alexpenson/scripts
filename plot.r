#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)
print(args)
if(length(args)) {
  filename <- args[[1]]
} else {
  filename <- "rplot.pdf"
}
print(filename)
d <- scan(file("stdin"), what=list(x=0,y=0), quiet=TRUE);
print(d$x)
print(d$y)
pdf(filename)
plot(d$x,d$y)
dev.off()
