#PGLS:
library(ape)
#install.packages('caper')
library(caper)

#install.packages('MuMIn')
library(MuMIn)

#install.packages("phylolm")
library(phylolm)

library(lmtest)
library(dplyr)
library(ggplot2)
library(patchwork)
library(phytools)
library(ggtree)
library(ggplot2)

install.packages("BiocManager")
BiocManager::install(c("treeio", "ggtree"))
library(treeio)

# Load datasets:
#####
solData <- read.csv("./inputs/inputClean/nicheMeanSummary.csv")
newLabels<-read.csv("./inputs/labels/NewTipLabels.csv")
newLabelsDiploid<-read.csv("./inputs/labels/NewTipLabelsDiploids.csv")

for (name in newLabels$oldLabel)
{
  solData$SP1[solData$SP1==name]=newLabels$Species[newLabels$oldLabel==name]
}
rownames(solData)<-solData$SP1

solData2<-subset(solData,solData$Ploidy=="Diploid")
for (name in newLabelsDiploid$oldLabel)
{
  solData2$SP1[solData2$SP1==name]=newLabelsDiploid$Species[newLabelsDiploid$oldLabel==name]
}
rownames(solData2)<-solData2$SP1

#######

#Exploratory plots:
#####
plot(solData$genomeSize ~ solData$mean.bio1)
plot(solData$genomeSize ~ solData$mean.bio2)
plot(solData$genomeSize ~ solData$mean.bio4)
plot(solData$genomeSize ~ solData$mean.bio12)
plot(solData$genomeSize ~ solData$mean.bio15)

plot(solData$gsMono ~ solData$mean.bio1)
plot(solData$gsMono ~ solData$mean.bio2)
plot(solData$gsMono ~ solData$mean.bio4)
plot(solData$gsMono ~ solData$mean.bio12)
plot(solData$gsMono ~ solData$mean.bio15)

plot(solData$genomeSize ~ solData$niche.bio1me)
plot(solData$genomeSize ~ solData$niche.bio2me)
plot(solData$genomeSize ~ solData$niche.bio4me)
plot(solData$genomeSize ~ solData$niche.bio12me)
plot(solData$genomeSize ~ solData$niche.bio15me)

plot(solData$gsMono ~ solData$niche.bio1me)
plot(solData$gsMono ~ solData$niche.bio2me)
plot(solData$gsMono ~ solData$niche.bio4me)
plot(solData$gsMono ~ solData$niche.bio12me)
plot(solData$gsMono ~ solData$niche.bio15me)
#######

# Load trees:
#####
bTree<-read.nexus("./inputs/inputRaw/BEAST2.tree")

trimTree<-drop.tip(bTree,c(3,7,8,14,33,35,38,41,59,75,80,81,83,84,98,107,117))
trimTree2<-drop.tip(bTree,c(1,3,4,7,8,10,14,19,29,33,35,36,38,41,43,45,47,48,53,59,60,73,75,80,81,83,84,91,96,98,107,113,117))
newLabels<-read.csv("./inputs/labels/NewTipLabels.csv")
newLabelsDiploid<-read.csv("./inputs/labels/NewTipLabelsDiploids.csv")
trimTree$tip.label<-newLabels$Species
trimTree2$tip.label<-newLabelsDiploid$Species
#######

# Make and examine PGLS models:
#####
solData.caperfilesFull <- comparative.data(trimTree, solData, SP1, vcv=TRUE)
solData.caperfilesDiploid <- comparative.data(trimTree2, solData2, SP1, vcv=TRUE)

solData.output.full2C.ind <- pgls(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+niche.bio1me+niche.bio2me+niche.bio4me+niche.bio12me+niche.bio15me+Ploidy, solData.caperfilesFull, lambda="ML")
solData.output.full2C.combo <- pgls(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+breadth+Ploidy, solData.caperfilesFull, lambda="ML")

solData.output.full1Cx.ind <- pgls(gsMono~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+niche.bio1me+niche.bio2me+niche.bio4me+niche.bio12me+niche.bio15me+Ploidy, solData.caperfilesFull, lambda="ML")
solData.output.full1Cx.combo <- pgls(gsMono~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+breadth+Ploidy, solData.caperfilesFull, lambda="ML")

solData.output.diploid2C.ind <- pgls(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+niche.bio1me+niche.bio2me+niche.bio4me+niche.bio12me+niche.bio15me, solData.caperfilesDiploid, lambda="ML")
solData.output.diploid2C.combo <- pgls(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+breadth, solData.caperfilesDiploid, lambda="ML")

summary(solData.output.full2C.ind)
summary(solData.output.full2C.combo)
summary(solData.output.full1Cx.ind)
summary(solData.output.full1Cx.combo)
summary(solData.output.diploid2C.ind)
summary(solData.output.diploid2C.combo)

saveRDS(solData.output.full2C.ind, "./outputs/PGLS/PGLSFull2Cind.rds")
saveRDS(solData.output.full2C.combo, "./outputs/PGLS/PGLSFull2Ccombo.rds")
saveRDS(solData.output.full1Cx.ind, "./outputs/PGLS/PGLSFull1Cxind.rds")
saveRDS(solData.output.full1Cx.combo, "./outputs/PGLS/PGLSFull1Cxcombo.rds")
saveRDS(solData.output.diploid2C.ind, "./outputs/PGLS/PGLSDiploid2Cind.rds")
saveRDS(solData.output.diploid2C.combo, "./outputs/PGLS/PGLSDiploid2Ccombo.rds")
#######

#Checking model fits:
#####
phylostepTest.full2C.ind<-phylostep(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+niche.bio1me+niche.bio2me+niche.bio4me+niche.bio12me+niche.bio15me+Ploidy,data=solData, phy=trimTree,model="lambda",direction="both" )
#Best model: mean.bio2 + niche.bio15me + Ploidy, AIC = 38.732640950283 (Full model AIC = 48.708626249318)
solData.output.full2C.ind.trim <- pgls(genomeSize~mean.bio2+niche.bio15me+Ploidy, solData.caperfilesFull, lambda="ML")
logLik(solData.output.full2C.ind) #full model log likelihood: -8.354313 (df=14)
logLik(solData.output.full2C.ind.trim) # trim model log likelihood: -12.36632 (df=5)
lrtest(solData.output.full2C.ind.trim,solData.output.full2C.ind) # Likelihood ratio = 12.425(df=9) P = 0.1904

phylostepTest.full2C.combo<-phylostep(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+breadth+Ploidy,data=solData, phy=trimTree,model="lambda",direction="both" )
#Best model: mean.bio1 + mean.bio2 + mean.bio4 + mean.bio12 + breadth + Ploidy, AIC = 41.5770214510853 (Full model AIC = 44.7854199974624)
solData.output.full2C.combo.trim <- pgls(genomeSize~mean.bio1+mean.bio2+mean.bio4+mean.bio12+breadth+Ploidy, solData.caperfilesFull, lambda="ML")
logLik(solData.output.full2C.combo) #full model log likelihood: -10.39271 (df=10)
logLik(solData.output.full2C.combo.trim) # trim model log likelihood: -12.36632 (df=8)
lrtest(solData.output.full2C.combo.trim,solData.output.full2C.combo) # Likelihood ratio = 0.7916(df=2) P = 0.6731

phylostepTest.full1Cx.ind<-phylostep(gsMono~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+niche.bio1me+niche.bio2me+niche.bio4me+niche.bio12me+niche.bio15me+Ploidy,data=solData, phy=trimTree,model="lambda",direction="both" )
# Best model: mean.bio2 + mean.bio15 + niche.bio15me, AIC = -158.450178716853 (Full model AIC = -144.140840304255)
solData.output.full1Cx.ind.trim <- pgls(gsMono~mean.bio2+mean.bio15+niche.bio15me, solData.caperfilesFull, lambda=0.812)  #estimating lambda here throws error: using estimate from full model instead
logLik(solData.output.full1Cx.ind) #full model log likelihood: 88.07042 (df=14)
logLik(solData.output.full1Cx.ind.trim) # trim model log likelihood: 85.17287 (df=4)
lrtest(solData.output.full1Cx.ind.trim,solData.output.full1Cx.ind) # Likelihood ratio = 5.7951(df=10) P = 0.8322

phylostepTest.full1Cx.combo<-phylostep(gsMono~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+breadth+Ploidy,data=solData, phy=trimTree,model="lambda",direction="both" )
# Best model: mean.bio2 + mean.bio12 + mean.bio15 + breadth, AIC = -154.76948572114 (full model: -148.657899783509)
solData.output.full1Cx.combo.trim <- pgls(gsMono~mean.bio2+mean.bio12+mean.bio15+breadth, solData.caperfilesFull, lambda="ML")
logLik(solData.output.full1Cx.combo) #full model log likelihood: 86.32895 (df=10)
logLik(solData.output.full1Cx.combo.trim) # trim model log likelihood: 84.38474 (df=5)
lrtest(solData.output.full1Cx.combo.trim,solData.output.full1Cx.combo) # Likelihood ratio = 3.8884(df=5) P = 0.5656

phylostepTest.diploid2C.ind<-phylostep(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+niche.bio1me+niche.bio2me+niche.bio4me+niche.bio12me+niche.bio15me,data=solData2, phy=trimTree2,model="lambda",direction="both" )
# Best model: mean.bio2 + mean.bio4 + niche.bio4me + niche.bio12me + niche.bio15me (Starting model: AIC = -12.4670880014314)
solData.output.diploid2C.ind.trim <- pgls(genomeSize~mean.bio2+mean.bio4+niche.bio4me+niche.bio12me+niche.bio15me, solData.caperfilesDiploid, lambda="ML")
logLik(solData.output.diploid2C.ind) #full model log likelihood: 20.23354 (df=12)
logLik(solData.output.diploid2C.ind.trim) #trim model log likelihood: 18.53335 (df=6)
lrtest(solData.output.diploid2C.ind.trim,solData.output.diploid2C.ind) # Likelihood ratio = 3.4004(df=6) P = 0.7572

phylostepTest.diploid2C.combo<-phylostep(genomeSize~mean.bio1+I(mean.bio1^2)+mean.bio2+mean.bio4+mean.bio12+mean.bio15+breadth,data=solData2, phy=trimTree2,model="lambda",direction="both" )
# Best model: mean.bio2 + mean.bio12 + mean.bio15 + breadth
solData.output.diploid2C.combo.trim <- pgls(genomeSize~mean.bio2+mean.bio12+mean.bio15+breadth, solData.caperfilesDiploid, lambda="ML")
logLik(solData.output.diploid2C.combo) #full model log likelihood: 15.51199 (df=8)
logLik(solData.output.diploid2C.combo.trim) #trim model log likelihood: 14.09616 (df=5)
lrtest(solData.output.diploid2C.combo.trim,solData.output.diploid2C.combo) # Likelihood ratio = 2.8317(df=3) P = 0.4183
#######
SpeciesNumbers<-solData %>% group_by(subClade) %>% tally()
View(SpeciesNumbers)

plot1<-ggplot(solData, aes(x=factor(subClade), y=genomeSize))+geom_boxplot()+ylab("2C Genome Size (pg)")+xlab("Minor Clade")+theme_bw(base_size=16)+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))+theme(axis.title.x=element_blank(),axis.text.x=element_blank())
#  geom_text(data=SpeciesNumbers,aes(clade,Inf,label=n),vjust=12.5)
plot2<-ggplot(solData, aes(x=factor(subClade), y=gsMono))+geom_boxplot()+ylab("1Cx Genome Size (pg)")+xlab("Minor Clade")+theme_bw(base_size=16)+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
#View (solData)

plot1/plot2
ggsave(filename = "./outputs/figures/genomeSizesBoxplot.pdf", width = 10, height = 10, device = "pdf")
dev.off()

#climate plots:
#######
newLabels<-read.csv("./inputs/labels/NewTipLabels.csv")
trimTree$tip.label<-newLabels$Species
trimTree$tip.label
map<-read.csv("./inputs/inputClean/climateOccs.csv")

for (name in newLabels$oldLabel)
{
  map$SP1[map$SP1 == name] = newLabels$Species[newLabels$oldLabel == name]
}
View(map)

bio1x<-setNames(map$bio1,map$SP1)
bio2x<-setNames(map$bio2,map$SP1)
bio4x<-setNames(map$bio4,map$SP1)
bio12x<-setNames(map$bio12,map$SP1)
bio15x<-setNames(map$bio15,map$SP1)

#bio2x<-subset(map, select=bio2)
names<-subset(map, select=SP1)
#?plotTree.boxplot

print(rownames(map))
View(map)
??plotTree.boxplot

dev.off()

pdf(file="./outputs/figures/climateBoxes/meanAnnTemp.pdf", width=5,height=10)
obj<-plotTree.boxplot(trimTree,bio1x,args.boxplot=list(xlab="Mean Annual Temperature\n(°C)",col="white",ylim=c(-5,30),outline=FALSE),args.plotTree=list(fsize=0.5))
dev.off()

pdf(file="./outputs/figures/climateBoxes/diurnalTempRange.pdf", width=5,height=10)
obj<-plotTree.boxplot(trimTree,bio2x,args.boxplot=list(xlab="Mean Diurnal\nTemperature Range (°C)",col="white",ylim=c(0,20),outline=FALSE),args.plotTree=list(fsize=0.5))
dev.off()

pdf(file="./outputs/figures/climateBoxes/tempSeas.pdf", width=5,height=10)
obj<-plotTree.boxplot(trimTree,bio4x,args.boxplot=list(xlab="Temperature Seasonality\n(°C)",col="white",outline=FALSE,ylim=c(0,10)),args.plotTree=list(fsize=0.5))
dev.off()

pdf(file="./outputs/figures/climateBoxes/totalAnnPrecip.pdf", width=5,height=10)
obj<-plotTree.boxplot(trimTree,bio12x,args.boxplot=list(xlab="Total Annual Precipitation\n(kg/m^2/yr)",col="white",ylim=c(0,10000),outline=FALSE),args.plotTree=list(fsize=0.5))
dev.off()

pdf(file="./ouputs/figures/climateBoxes/precipSeas.pdf", width=5,height=10)
obj<-plotTree.boxplot(trimTree,bio15x,args.boxplot=list(xlab="Precipitation Seasonality\n(kg/m^2)",col="white",ylim=c(0,150),outline=FALSE),args.plotTree=list(fsize=0.5))
dev.off()
#######
