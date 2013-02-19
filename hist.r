#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly=TRUE)

filename <- "rplot.pdf"
if(length(args)) { filename <- args[[1]] } 


d <- scan(file("stdin"), what=list(x=0), quiet=TRUE);

#############################################
## PLOT
pdf(filename)
if(length(args) >= 4) {
    xmin <- as.integer(args[[2]])
    xmax <- as.integer(args[[3]])
    xby <-  as.integer(args[[4]])
    d$x_reduced <- d$x[d$x>xmin & d$x<xmax]
    hist(d$x_reduced, main=filename, breaks=seq(xmin,xmax,by=xby))
} else if(length(args) >= 2) {
    hist(d$x, main=filename, breaks=as.integer(args[[2]]))
} else {
    hist(d$x, main=filename)	
}
dev.off()
