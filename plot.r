#!/usr/bin/env Rscript
d <- scan(file("stdin"), what=list(x=0,y=0), quiet=TRUE);
print(d$x)
print(d$y)
pdf('rplot.pdf')
plot(d$x,d$y)
dev.off()
