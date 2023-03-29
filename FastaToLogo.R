library(DiffLogo)
library(seqLogo)

args = commandArgs(trailingOnly=TRUE)
pwm = getPwmFromFastaFile(args[1])
write.table(data = pwm, args[2])

png(args[3], width=5.25,height=3.25,units="in",res=800)
seqLogo(pwm = pwm)
dev.off()
