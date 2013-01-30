#!/usr/bin/env Rscript
d <- scan(file("stdin"), c(0), quiet=TRUE);
summary(d)
cat("sd =", signif(sd(d),digits=4), fill=TRUE)
