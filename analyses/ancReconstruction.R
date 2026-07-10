# ancReconstruction.R

solData <- read.csv("./inputs/inputClean/nicheMeanSummary.csv")
newLabels <- read.csv("./inputs/labels/newTipLabels.csv")
newLabelsDiploid <- read.csv("./inputs/labels/newTipLabelsDiploids.csv")

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

library(ggtree)
library(ggplot2)
library(phytools)
library(ape)

#install.packages("viridis")
library(viridis)
library(treeio)
#install.packages('plotrix')
#library (plotrix)

# Full Trees:
#####
# Read in Bayesian tree
bTree<-read.beast("./inputs/inputRaw/BEAST2.tree")
newLabelsFull<-read.csv("./inputs/labels/NewTipLabelsFull.csv")
bTree@phylo$tip.label<-newLabelsFull$Species
ggtree(bTree,layout="fan")+geom_nodepoint(aes(colour=posterior),size=3)+geom_tiplab(size=1.9)+scale_colour_viridis(begin = 1, end = 0)+theme(legend.position=c(0.1,0.10))+labs(colour="posterior\nprobability")
ggsave(filename = "./outputs/figures/BayesianTreeFull.pdf", width = 10, height = 10, device = "pdf")

# Read in Max Likelihood tree
MLTree<-read.tree("./inputs/inputRaw/IQ3.fasta.contree")
newLabelsFull<-read.csv("./inputs/labels/NewTipLabelsFullIQ.csv")
MLTree$tip.label<-newLabelsFull$Species
MLTree <-root(phy = MLTree, outgroup = "S._dulcamara_2x",edgelabel=TRUE)
ggtree(MLTree,layout="fan")+geom_nodepoint(aes(colour=as.numeric(label)),size=3)+geom_tiplab(size=1.9)+scale_colour_viridis(begin = 1, end = 0)+theme(legend.position=c(0.1,0.10))+labs(colour="Bootstrap (%)")#+ geom_label2(aes(label=label, subset = !isTip))
ggsave(filename = "./outputs/figures/MLTreeFull.pdf", width = 10, height = 10, device = "pdf")
#######

# Check phylogenetic signal:
#####
bTree<-read.nexus("./inputs/inputRaw/BEAST2.tree")

trimTree<-drop.tip(bTree,c(3,7,8,14,33,35,38,41,59,75,80,81,83,84,98,107,117))
trimTree2<-drop.tip(bTree,c(1,3,4,7,8,10,14,19,29,33,35,36,38,41,43,45,47,48,53,59,60,73,75,80,81,83,84,91,96,98,107,113,117))
newLabels<-read.csv("./inputs/labels/NewTipLabels.csv")
newLabelsDiploid<-read.csv("./inputs/labels/NewTipLabelsDiploids.csv")

trimTree$tip.label<-newLabels$Species
trimTree2$tip.label<-newLabelsDiploid$Species

plot(trimTree2, cex=0.5, type="fan")

data.GSE.Full2C<-setNames(solData$genomeSize,rownames(solData))
data.GSE.Full1Cx<-setNames(solData$gsMono,rownames(solData))
data.GSE.Diploid2C<-setNames(solData2$genomeSize,rownames(solData2))

GSE.Pagel.lambdaFull2C<-phylosig(trimTree, data.GSE.Full2C, method="lambda", test=TRUE)
GSE.Pagel.lambdaFull1Cx<-phylosig(trimTree, data.GSE.Full1Cx, method="lambda", test=TRUE)
GSE.Pagel.lambdaDiploid2C<-phylosig(trimTree2, data.GSE.Diploid2C, method="lambda", test=TRUE)

GSE.Pagel.lambdaFull1Cx
GSE.Pagel.lambdaDiploid2C
#Moderate to strong: >1, Weak to Moderate: 0 to 1, none if nonsig from 0
#if equal to one, pretty much similar to shared ancestry; aligns with Brownian model
#If 0, no phylogenetic relationship

saveRDS(GSE.Pagel.lambdaFull2C, "./outputs/ancRec/lambdaFull2C.rds")
saveRDS(GSE.Pagel.lambdaFull1Cx, "./outputs/ancRec/lambdaFull1Cx.rds")
saveRDS(GSE.Pagel.lambdaDiploid2C, "./outputs/ancRec/lambdaDiploid2C.rds")
#######

#Reconstruction/saving ancestral states:
#####
ancRecFull2C<-fastAnc(trimTree,data.GSE.Full2C, CI = TRUE)
ancRecFull1Cx<-fastAnc(trimTree,data.GSE.Full1Cx, CI = TRUE)
ancRecDiploid2C<-fastAnc(trimTree2,data.GSE.Diploid2C, CI = TRUE)

ancRecFull1Cx
ancRecDiploid2C

write.csv(ancRecFull2C$ace, "./outputs/ancRec/Full2CEstimates.csv")
write.csv(ancRecFull2C$CI95, "./outputs/ancRec/Full2C.CIs.csv")

write.csv(ancRecFull1Cx$ace, "./outputs/ancRec/Full1CxEstimates.csv")
write.csv(ancRecFull1Cx$CI95, "./outputs/ancRec/Full1Cx.CIs.csv")

write.csv(ancRecDiploid2C$ace, "./outputs/ancRec/Diploid2CEstimates.csv")
write.csv(ancRecDiploid2C$CI95, "./outputs/ancRec/Diploid2C.CIs.csv")

#Save node labels
pdf(file="./outputs/ancRec/diploidTreeNodeMap.pdf")
plot(trimTree2,cex=0.5,type="fan")
nodelabels(text=rownames(ancRecDiploid2C$CI95),cex=0.25,frame="circle")
dev.off()

pdf(file="./outputs/ancRec/fullTreeNodeMap.pdf")
plot(trimTree,cex=0.5,type="fan")
nodelabels(text=rownames(ancRecFull2C$CI95),cex=0.25,frame="circle")
dev.off()

GSE.contMapFull2C<-contMap(trimTree,data.GSE.Full2C, plot=FALSE, res=200)
GSE.contMapFull2C<-setMap(GSE.contMapFull2C, colors=viridis(n=200, direction=-1))

GSE.contMapFull1Cx<-contMap(trimTree,data.GSE.Full1Cx, plot=FALSE, res=200)
GSE.contMapFull1Cx<-setMap(GSE.contMapFull1Cx, colors=viridis(n=200, direction=-1))

GSE.contMapDiploid2C<-contMap(trimTree2,data.GSE.Diploid2C, plot=FALSE, res=200)
GSE.contMapDiploid2C<-setMap(GSE.contMapDiploid2C, colors=viridis(n=200, direction=-1))

pdf(file="./outputs/figures/ancRecFigure.pdf",width=8,height=5)
par(mfrow=c(1,3))
plot(GSE.contMapFull2C,fsize=c(0.5,0.6), leg.txt="2C Genome Size (pg)", lwd=3)
plot(GSE.contMapFull1Cx,fsize=c(0.5,0.6), leg.txt="1Cx Genome Size (pg)", lwd=3)
plot(GSE.contMapDiploid2C,fsize=c(0.5,0.6), leg.txt="2C Genome Size (pg)", lwd=3)
dev.off()
