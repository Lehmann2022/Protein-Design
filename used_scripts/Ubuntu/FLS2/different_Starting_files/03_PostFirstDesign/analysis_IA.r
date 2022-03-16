
args <- commandArgs(TRUE)
csv_file=args[1]
png_PreDesign=args[2]
png_PostDesign=args[3]
png_ScoreCorr=args[4]
png_Mutations=args[5]
png_I_Sc=args[6]
png_Comparison=args[7]
name1=args[8]
name2=args[9]
name3=args[10]
name4=args[11]
nameofFolder=args[12]
CSV=args[13]



data <- read.csv(csv_file, header=TRUE, sep=";")



png(file=png_PreDesign,width=800, height=800,res=120)
hist(data$dG_preDesign, main=name1, xlab="Interaction score", xlim=c(-120,0), col="royalblue")
dev.off()
png(file=png_PostDesign,width=800, height=800,res=120)
hist(data$dG_postDesign, main=name2, xlab="Interaction_score", xlim=c(-120,-0), col="darkgreen")
dev.off()
png(file=png_ScoreCorr,width=800, height=800,res=120)
plot(data$dG_preDesign, data$dG_postDesign, xlab="PreDesign", ylab="PostDesign", main=name3)
dev.off()
png(file=png_Mutations,width=800, height=800,res=120)
plot(data$Mutations,data$dG_postDesign, main=name4, xlab="Number of mutations",ylab="Interaction score")
dev.off()
#png(file=png_file5,width=800, height=800,res=120)
#hist(data$PostDock, main=name5, xlab="Interaction score", col="deepskyblue")
#dev.off()
png(file=png_Comparison,width=800, height=800,res=120)
par(mfrow=c(2,3))
#hist(data$PostDock, main="Post Docking", xlab="Interaction score", col="deepskyblue")
hist(data$dG_preDesign, main=name1, xlab="Interaction score", xlim=c(-120,0), col="royalblue")
hist(data$dG_postDesign, main=name2, xlab="Interaction score", xlim=c(-120,0), col="darkgreen")
dev.off()

set.seed(42)

png(file=png_PreDesign,width=800, height=800,res=120)
a <- hist(data$dG_preDesign, main=name1, xlab="Interaction score", xlim=c(-120,0), col="royalblue")
png(file=png_Comparison,width=800, height=800,res=120)
b <- hist(data$dG_postDesign, xlab="Interaction_score", col="royalblue3")

plot(a, main="Comparison", xlab="Interaction_score", col=rgb(0,0.8,1,1/4), xlim=c(-120,0))
plot(b, col=rgb(0,0.2,0.6,1/4), xlim=c(-120,-60), add=T)
legend("topright", c(name1, name2), pch=15, col=c(rgb(0,0.8,1,1/4), rgb(0,0.2,0.6,1/4)), cex=0.575)
dev.off()

df <- data.frame(Folder = nameofFolder, Quartil = quantile(data$dG_postDesign, prob = c(0.25)))
write.csv(df, file=CSV, row.names=FALSE)
dev.off()

