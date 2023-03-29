library(DiffLogo)
library(seqLogo)

args = commandArgs(trailingOnly=TRUE)
pwm = getPwmFromFastaFile(args[1])
png('test.png', width=5.25,height=3.25,units="in",res=800)
seqLogo(pwm = pwm)
dev.off()
