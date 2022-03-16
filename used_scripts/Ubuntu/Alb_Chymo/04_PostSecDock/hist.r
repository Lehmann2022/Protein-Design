
args <- commandArgs(TRUE)
csv_file=args[1]
png_file1=args[2]
name1=args[3]


data <- read.csv(csv_file, header=TRUE, sep=";")

png(file=png_file1,width=800, height=800,res=120)
hist(data$PostRelax1, main=name1, xlab="Interaction score", xlim=c(-140,-70), col="blue")
dev.off()







