
args <- commandArgs(TRUE)
csv_file=args[1]
png_file1=args[2]
png_file2=args[3]
png_file3=args[4]
png_file4=args[5]
png_file5=args[6]
png_file6=args[7]
png_file7=args[13]
name1=args[8]
name2=args[9]
name3=args[10]
name4=args[11]
name5=args[12]

data <- read.csv(csv_file, header=TRUE, sep=";")

png(file=png_file1,width=800, height=800,res=120)
hist(data$PostRelax1, main=name1, xlab="Interaction score", xlim=c(-120,-30), col="royalblue")
dev.off()
png(file=png_file2,width=800, height=800,res=120)
hist(data$PostRelax2, main=name2, xlab="Interaction_score", xlim=c(-120,-30), col="darkgreen")
dev.off()
png(file=png_file3,width=800, height=800,res=120)
plot(data$PostRelax1, data$PostRelax2, xlab="PreDesign", ylab="PostDesign", main=name3)
dev.off()
png(file=png_file4,width=800, height=800,res=120)
plot(data$Mutations,data$PostRelax2, main=name4, xlab="Number of mutations",ylab="Interaction score")
dev.off()
#png(file=png_file5,width=800, height=800,res=120)
#hist(data$PostDock, main=name5, xlab="Interaction score", col="deepskyblue")
#dev.off()
png(file=png_file6,width=800, height=800,res=120)
par(mfrow=c(2,3))
#hist(data$PostDock, main="Post Docking", xlab="Interaction score", col="deepskyblue")
hist(data$PostRelax1, main=name1, xlab="Interaction score", xlim=c(-120,-30), col="royalblue")
hist(data$PostRelax2, main=name2, xlab="Interaction score", xlim=c(-120, -30), col="darkgreen")
dev.off()

set.seed(42)

png(file=png_file1,width=800, height=800,res=120)
a <- hist(data$PostRelax1, main=name1, xlab="Interaction score", xlim=c(-120,-60), col="royalblue")
png(file=png_file7,width=800, height=800,res=120)
b <- hist(data$PostRelax2, xlab="Interaction_score", col="royalblue3")

plot(a, main="Comparison", xlab="Interaction_score", col=rgb(0,0.8,1,1/4), xlim=c(-120,-60))
plot(b, col=rgb(0,0.2,0.6,1/4), xlim=c(-120,-60), add=T)
legend("topright", c(name1, name2), pch=15, col=c(rgb(0,0.8,1,1/4), rgb(0,0.2,0.6,1/4)), cex=0.575)






