#!/usr/bin/env Rscript
d <- scan(file("stdin"), c(0), quiet=TRUE);
summary(d)
cat("sd =", signif(sd(d[sapply(d, is.numeric)]),digits=4), fill=TRUE)
