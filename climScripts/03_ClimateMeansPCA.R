# 03_climateMeansPCA: Script for checking PCA correlations of climate variable means
# June 2026, Delaney McTavish-McHugh, mctavisd@uoguelph.ca

library(factoextra)
library(FactoMineR)
library("corrplot")
#install.packages("Hmisc")
library("Hmisc")

solMap<-read.csv("./inputs/inputClean/summaryClimValues.csv")

dim(solMap)

PCAA<-data.frame(SP1=solMap$SP1, bio1_annMeanT=solMap$mean.bio1,bio2_MeanDiTRange=solMap$mean.bio2,
                 bio3_Isotherm=solMap$mean.bio3,bio4_TempSeas=solMap$mean.bio4,
                 bio5_MaxWarmestM=solMap$mean.bio5,bio6_MinColdestM=solMap$mean.bio6,bio7_AnnTempRange=solMap$mean.bio7,
                 bio12_AnnMeanPrecip=solMap$mean.bio12,bio13_MaxWettestM=solMap$mean.bio13,
                 bio14_MinDriestM=solMap$mean.bio14,bio15_PrecipSeas=solMap$mean.bio15,
                 cmimean=solMap$mean.cmimean,cmirange=solMap$mean.cmirange,gsl=solMap$mean.gsl,
                 swb=solMap$mean.swb,cmimax=solMap$mean.cmimax,cmimin=solMap$mean.cmimin,
                 gdd5=solMap$mean.gdd5,CCmean=solMap$mean.CCmean, CCSD=solMap$mean.CCSD)

PCA2<-PCAA[1:100,2:21]
res.pca<-PCA(PCA2,graph=FALSE)

print(res.pca)

eig.val<-get_eigenvalue(res.pca)
eig.val

fviz_eig(res.pca, addlabels = TRUE, ylim = c(0, 60))

var<-get_pca_var(res.pca)
var

head(var$coord,13)
head(var$cor)
fviz_pca_var(res.pca,col.var="black")

corrplot(var$coord,is.corr=FALSE)
fviz_cos2(res.pca, choice = "var", axes = 1)

sol.corr<-cor(PCA2)
sol.corr.sig<-rcorr(as.matrix(PCA2))

sol.corr.sig$P[is.na(sol.corr.sig$P)] <- 0

corrplot(sol.corr.sig$r, type="upper", order="hclust",p.mat=sol.corr.sig$P,
         tl.col="black", tl.srt=45,sig.level=0.01,insig="blank")

View(sol.corr.sig$r)
write.csv(sol.corr.sig$r,"./outputs/climate/climateCorrs.csv")

fviz_pca_var(res.pca, col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"), 
             repel = TRUE # Avoid text overlapping
)

fviz_pca_var(res.pca, alpha.var = "coord")
head(var$contrib, 4)

corrplot(var$contrib, is.corr=FALSE)
fviz_contrib(res.pca, choice = "var", axes = 1, top = 12)
fviz_contrib(res.pca, choice = "var", axes = 2, top = 5)
fviz_contrib(res.pca, choice = "var", axes = 3, top = 8)

fviz_contrib(res.pca, choice = "var", axes = 1:3, top = 20)
