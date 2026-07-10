# 04_nicheCorr: Script for checking correlations of climate variable means and niche breadths
# June 2026, Delaney McTavish-McHugh, mctavisd@uoguelph.ca

#install.packages("Hmisc")
library("Hmisc")

solMap<-read.csv("./inputs/inputClean/nicheMeanSummary.csv")

dim(solMap)
View (solMap)

PCAA<-data.frame(SP1=solMap$SP1, Ploidy=solMap$Ploidy, subclade=solMap$subClade, niche1=solMap$niche.bio1me,
                 niche2=solMap$niche.bio2me,niche4=solMap$niche.bio4me,niche12=solMap$niche.bio12me,niche15=solMap$niche.bio15me,
                 bio1_annMeanT=solMap$mean.bio1,bio2_MeanDiTRange=solMap$mean.bio2,bio4_TempSeas=solMap$mean.bio4,
                 bio12_AnnMeanPrecip=solMap$mean.bio12,bio15_PrecipSeas=solMap$mean.bio15
)

PCA2<-PCAA[,4:13]
sol.corr<-cor(PCA2)
sol.corr.sig<-rcorr(as.matrix(PCA2))

View(sol.corr.sig$r)
write.csv(sol.corr.sig$r,"./outputs/climate/nicheMeanCorrs.csv")
