# 02_climateAssign: Script for assigning climate variables to occurrence data
#June 2026, Delaney McTavish-McHugh, mctavisd@uoguelph.ca

#####
library(dplyr)
library(viridis)
library(EnvStats)
library(raster)
library(ggplot2)
library(tidyverse)

#data(wrld_simpl)
sol<-read.csv("./inputs/inputClean/DF_results_all_spatial_filtering.csv")
table(sol$SP1)

layers <- list.files("./chelsa",pattern='tif',full.names=TRUE)
list(layers)

# Make columns for genome size data and subclades:
sol$genomeSize<-"NA"
sol$GenomeSizeMethod<-"NA"
sol$subclade<-"NA"
sol$PClade<-"NA"

# Assigning Minor Clades:
#####
clades<-read.csv("./inputs/filterFiles/clades.csv")
for (name in clades$Species)
{
  sol$subclade[sol$Species==name] = clades$clade[clades$Species==name]
  sol$PClade[sol$Species==name] = clades$PClade[clades$Species==name]
}
#######

# Assigning flow cytometry-based Genome Sizes to occurrences (keeping ploidy levels in mind):
#####
FCM<-read.csv("./inputs/filterFiles/FCM.csv")
#View(clades)

for (name in FCM$Species)
{
  sol$GenomeSizeMethod[sol$SP1==name] = "FCM"
  if (grepl("acroscopicum",name)|grepl("andreanum",name)|grepl("brevicaule",name))
  {
    sol$genomeSize[sol$SP1==name&sol$Ploidy=="24"] = FCM$genomeSize[FCM$Species==name&FCM$ChrNumber=="24"] 
    sol$genomeSize[sol$SP1==name&sol$Ploidy=="48"] = FCM$genomeSize[FCM$Species==name&FCM$ChrNumber=="48"]
  }
  else
  {
    sol$genomeSize[sol$SP1==name] = FCM$genomeSize[FCM$Species==name] 
    sol$Ploidy[sol$SP1==name] = FCM$ChrNumber[FCM$Species==name]
  }
}

#View(sol)
#######

# Assigning LocoGSE Genome Sizes to occurrences:
#####
Loco<-read.csv("./inputs/filterFiles/LocoGSE.csv")
#View(Loco)
for (name in Loco$Species)
{
  sol$GenomeSizeMethod[sol$SP1==name] = "LocoGSE"
  sol$genomeSize[sol$SP1==name] = Loco$genomeSize[Loco$Species==name] 
  sol$Ploidy[sol$SP1==name] = Loco$ChrNumber[Loco$Species==name]
}

#######
#Remove occurrences with no genome sizes:
solFCM<-subset(sol,(genomeSize!="NA"))
dim(solFCM) # 3771

#Remove species with unreliable genome sizes & single tetraploid acroscopicum:
solFCM<-subset(solFCM,(SP1!="acroscopicum_48"))
solFCM<-subset(solFCM,(SP1!="phaseoloides"))
solFCM<-subset(solFCM,(SP1!="pentaphyllum"))
dim(solFCM) # 3735

write.csv(solFCM,file="./outputs/climate/GSAssigned.csv", row.names=FALSE)

# Assigning climate variables:                    
#################################################

layers <- list.files("./inputs/chelsa",pattern='tif',full.names=TRUE)
list(layers)

#Mean Annual Temp:
#####
predictors <-stack(layers[[1]])
predictors
plot(predictors, 1)

bio1_values<-raster::extract(predictors,solFCM[,9:8])
bio1_values1<-data.frame(bio1_values)
str(bio1_values1)

solFCM$bio1<-bio1_values1$CHELSA_bio01_1981.2010_V.2.1
table(is.na(solFCM$bio1)) #Check if any occs have missing values
#######

# Mean Diurnal Temperature Range:
#####
predictors <-stack(layers[[2]])

bio2_values<-raster::extract(predictors,solFCM[,9:8])
bio2_values1<-data.frame(bio2_values)
str(bio2_values1)

solFCM$bio2<-bio2_values1$CHELSA_bio02_1981.2010_V.2.1
table(is.na(solFCM$bio2))
#######

#Isothermality:
#####
predictors <-stack(layers[[3]])

bio3_values<-raster::extract(predictors,solFCM[,9:8])
bio3_values1<-data.frame(bio3_values)
str(bio3_values1)

solFCM$bio3<-bio3_values1$CHELSA_bio03_1981.2010_V.2.1
table(is.na(solFCM$bio3))
#######

#Temp Seasonality:
#####
predictors <-stack(layers[[4]])

bio4_values<-raster::extract(predictors,solFCM[,9:8])
bio4_values1<-data.frame(bio4_values)
str(bio4_values1)

solFCM$bio4<-bio4_values1$CHELSA_bio04_1981.2010_V.2.1
table(is.na(solFCM$bio4))
#######

#Max Temp Hottest Month:
#####
predictors <-stack(layers[[5]])

bio5_values<-raster::extract(predictors,solFCM[,9:8])
bio5_values1<-data.frame(bio5_values)
str(bio5_values1)

solFCM$bio5<-bio5_values1$CHELSA_bio05_1981.2010_V.2.1
table(is.na(solFCM$bio5))
#######

#Min Temp Coldest Month:
#####
predictors <-stack(layers[[6]])

bio6_values<-raster::extract(predictors,solFCM[,9:8])
bio6_values1<-data.frame(bio6_values)
str(bio6_values1)

solFCM$bio6<-bio6_values1$CHELSA_bio06_1981.2010_V.2.1
table(is.na(solFCM$bio6))
#######

#Annual Temp Range:
#####
predictors <-stack(layers[[7]])

bio7_values<-raster::extract(predictors,solFCM[,9:8])
bio7_values1<-data.frame(bio7_values)
str(bio7_values1)

solFCM$bio7<-bio7_values1$CHELSA_bio07_1981.2010_V.2.1
table(is.na(solFCM$bio7))
#######

#Annual Precipitation:
#####
predictors <-stack(layers[[8]])

bio12_values<-raster::extract(predictors,solFCM[,9:8])
bio12_values1<-data.frame(bio12_values)
str(bio12_values1)

solFCM$bio12<-bio12_values1$CHELSA_bio12_1981.2010_V.2.1
table(is.na(solFCM$bio12))
#######

#Precip. Wettest Month:
#####
predictors <-stack(layers[[9]])

bio13_values<-raster::extract(predictors,solFCM[,9:8])
bio13_values1<-data.frame(bio13_values)
str(bio13_values1)

solFCM$bio13<-bio13_values1$CHELSA_bio13_1981.2010_V.2.1
table(is.na(solFCM$bio13))
#######

#Precip. Driest Month:
#####
predictors <-stack(layers[[10]])

bio14_values<-raster::extract(predictors,solFCM[,9:8])
bio14_values1<-data.frame(bio14_values)
str(bio14_values1)

solFCM$bio14<-bio14_values1$CHELSA_bio14_1981.2010_V.2.1
table(is.na(solFCM$bio14))
#######

#Precip. Seasonality:
#####
predictors <-stack(layers[[11]])

bio15_values<-raster::extract(predictors,solFCM[,9:8])
bio15_values1<-data.frame(bio15_values)
str(bio15_values1)

solFCM$bio15<-bio15_values1$CHELSA_bio15_1981.2010_V.2.1
table(is.na(solFCM$bio15))
#######

#Climate Moisture Index (Max):
#####
predictors <-stack(layers[[12]])

cmimax_values<-raster::extract(predictors,solFCM[,9:8])
cmimax_values1<-data.frame(cmimax_values)
str(cmimax_values1)

solFCM$cmimax<-cmimax_values1$CHELSA_cmimax_1981.2010_V.2.1
table(is.na(solFCM$cmimax))
#######

#Climate Moisture Index (Mean):
#####
predictors <-stack(layers[[13]])

cmimean_values<-raster::extract(predictors,solFCM[,9:8])
cmimean_values1<-data.frame(cmimean_values)
str(cmimean_values1)

solFCM$cmimean<-cmimean_values1$CHELSA_cmimean_1981.2010_V.2.1
table(is.na(solFCM$cmimean))
#######

#Climate Moisture Index (Min monthly):
#####
predictors <-stack(layers[[14]])

cmimin_values<-raster::extract(predictors,solFCM[,9:8])
cmimin_values1<-data.frame(cmimin_values)
str(cmimin_values1)

solFCM$cmimin<-cmimin_values1$CHELSA_cmimin_1981.2010_V.2.1
table(is.na(solFCM$cmimin))
#######

#Climate Moisture Index (Annual Range):
#####
predictors <-stack(layers[[15]])

cmirange_values<-raster::extract(predictors,solFCM[,9:8])
cmirange_values1<-data.frame(cmirange_values)
str(cmirange_values1)

solFCM$cmirange<-cmirange_values1$CHELSA_cmirange_1981.2010_V.2.1
table(is.na(solFCM$cmirange))
#######

#Growing Season Length:
#####
predictors <-stack(layers[[17]])

gsl_values<-raster::extract(predictors,solFCM[,9:8])
gsl_values1<-data.frame(gsl_values)
str(gsl_values1)

solFCM$gsl<-gsl_values1$CHELSA_gsl_1981.2010_V.2.1
table(is.na(solFCM$gsl))
#######

#Site Water Balance:
#####
predictors <-stack(layers[[18]])

swb_values<-raster::extract(predictors,solFCM[,9:8])
swb_values1<-data.frame(swb_values)
str(swb_values1)

solFCM$swb<-swb_values1$CHELSA_swb_1981.2010_V.2.1
table(is.na(solFCM$swb))
#12 occurrences not filled
#######

#gdd5:
#####
predictors <-stack(layers[[16]])

gdd5_values<-raster::extract(predictors,solFCM[,9:8])
gdd5_values1<-data.frame(gdd5_values)
str(gdd5_values1)

solFCM$gdd5<-gdd5_values1$CHELSA_gdd5_1981.2010_V.2.1
table(is.na(solFCM$gdd5))
#######

#CCmean:
#####
predictors <-stack(layers[[20]])

CCmean_values<-raster::extract(predictors,solFCM[,9:8])
CCmean_values1<-data.frame(CCmean_values)
str(CCmean_values1)

solFCM$CCmean<-CCmean_values1$MODCF_meanannual
table(is.na(solFCM$CCmean)) #363 missing values
#######

#CCSD:
#####
predictors <-stack(layers[[19]])

CCSD_values<-raster::extract(predictors,solFCM[,9:8])
CCSD_values1<-data.frame(CCSD_values)
str(CCSD_values1)

solFCM$CCSD<-CCSD_values1$MODCF_intraannualSD
table(is.na(solFCM$CCSD)) #363 missing values
#######

dev.off()

# Unit Conversions:
#####
solFCM$CCmean<-solFCM$CCmean*0.01
solFCM$CCSD<-solFCM$CCSD*0.01
solFCM$bio4<-solFCM$bio4/100

#######

#Setting 1Cx genome sizes:
#####
solFCM$genomeSize<-as.numeric(solFCM$genomeSize)

solFCM$gsMono<-(solFCM$genomeSize/((solFCM$Ploidy)/12))
solFCM$gsMono<-ifelse(is.na(solFCM$gsMono),solFCM$genomeSize,solFCM$gsMono)
#######

#Saving Progress:
write.csv(solFCM,"./inputs/inputClean/climateOccs.csv", row.names=FALSE)

#Map-making:
#####
wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
mapRaw<-read.csv("./inputs/inputClean/climateOccs.csv")
sol.names<-unique(mapRaw$SP1)

number.records<-matrix(,nrow=length(unique(mapRaw$SP1)),ncol=2)
rownames(number.records)<-unique(mapRaw$SP1)
mapRaw$Source<-factor(mapRaw$Source)
occurrence.records<-list()

mapRaw <- mapRaw %>%
  mutate(subclade = fct_relevel(subclade, 
                            "Petota", "Tomato", "Basarthrum", 
                            "Pteroidea", "Anarrhichomenum", "Articulatum", 
                            "Etuberosum", "Herpystichum","Oxycoccoides"))

plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mapRaw, aes(x = LONGDEC, y = LATDEC, colour = genomeSize),cex=0.5, shape = 16)+scale_colour_viridis(begin = 1, end = 0)+
  theme_bw()+coord_sf(xlim=c(-115,-54), ylim = c(-45,40))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+theme(legend.position=c(0.2,0.10),legend.direction="horizontal")+guides(colour = guide_colourbar(title.position = "top"))+labs(colour="2C Genome Size (pg)")
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))
ggsave(filename = "./outputs/figures/2C_occMap.pdf", width = 5, height = 7, device = "pdf")

#View(mapRaw)
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mapRaw, aes(x = LONGDEC, y = LATDEC, colour = gsMono),cex=0.75, shape = 16)+scale_colour_viridis(begin = 1, end = 0)+
  theme_bw()+coord_sf(xlim=c(-115,-54), ylim = c(-45,40))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+theme(legend.position=c(0.2,0.10),legend.direction="horizontal")+guides(colour = guide_colourbar(title.position = "top"))+labs(colour="1Cx Genome Size (pg)")
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))
ggsave(filename = "./outputs/figures/1Cx_occMap.pdf", width = 5, height = 7, device = "pdf")

dev.off()

#######

#Calculating mean values:
#####
sp<-read.csv("./inputs/inputClean/climateOccs.csv")

# Climate range function: calculate max - min values
climrange <- function(x) {  
  (max(x) - min(x))
}

sp_n <- sp

#Calculate ranges over all species
sp_n$range.bio1 <- climrange(sp_n$bio1)
sp_n$range.bio2 <- climrange(sp_n$bio2)
sp_n$range.bio3 <- climrange(sp_n$bio3)
sp_n$range.bio4 <- climrange(sp_n$bio4)
sp_n$range.bio5 <- climrange(sp_n$bio5)
sp_n$range.bio6 <- climrange(sp_n$bio6)
sp_n$range.bio7 <- climrange(sp_n$bio7)
sp_n$range.bio12 <- climrange(sp_n$bio12)
sp_n$range.bio13 <- climrange(sp_n$bio13)
sp_n$range.bio14 <- climrange(sp_n$bio14)
sp_n$range.bio15 <- climrange(sp_n$bio15)
sp_n$range.cmimax <- climrange(sp_n$cmimax)
sp_n$range.cmimean <- climrange(sp_n$cmimean)
sp_n$range.cmimin <- climrange(sp_n$cmimin)
sp_n$range.gdd5 <- climrange(sp_n$gdd5)
sp_n$range.cmirange <- climrange(sp_n$cmirange)
sp_n$range.CCmean <- climrange(sp_n$CCmean)
sp_n$range.CCSD <- climrange(sp_n$CCSD)
gslfiltered<-na.omit(sp_n$gsl) #to remove NA values
swbfiltered<-na.omit(sp_n$swb)
sp_n$range.gsl <- climrange(gslfiltered)
sp_n$range.swb <- climrange(swbfiltered)

## dplyr
a <- sp_n %>%
  dplyr::group_by(SP1) %>%
  dplyr::mutate(Specimens = n())

a <- as.data.frame(a)
#View(a)
dim(a)

#Saving Progress:
write.csv(a,"./inputs/inputClean/climateOccsWithSpecies.csv", row.names=FALSE)

#Number of specimens
b <- as.data.frame(sp %>%
                     group_by(SP1) %>%
                     dplyr::summarise(Specimens = n()))

dim(b)
b.c<-b
b.c

sp_u10 <-dplyr::filter(a, Specimens < 10)
sp_o10 <-dplyr::filter(a, Specimens >= 10)
spfilt_u10 <-dplyr::filter(a, SP1 %in% sp_u10$SP1)
spfilt_o10 <-dplyr::filter(a, SP1 %in% sp_o10$SP1)

###############################
#The next section here is getting some stats and exploring the dataset
### Number of specimens for each species:

quantile(b$Specimens)
#0%  25%  50%  75% 100% 
#1    9   20   41.25  194

#Less than 10
#Less than 20
#Less than 35
#More than 35
u10 <-dplyr::filter(b, Specimens < 10)
u20 <-dplyr::filter(b, Specimens < 20)
u35 <-dplyr::filter(b, Specimens < 35)
o35 <-dplyr::filter(b, Specimens >= 35)

dim(u10)
dim(u20)
dim(u35)
dim(o35)

cat.ab<-rbind(u35,o35) # This file lets me see how many species are in each category.
View(cat.ab)#100, 2
write.csv(cat.ab,"./outputs/climate/noOccsPerSpecies.csv", row.names=FALSE)

dim(sp)#3735
dim(sp_o10)#3589

check_shapiro <- function(x) {
  if (length(x)<2) return (NA)
  tryCatch(shapiro.test(x)$p.value,error=function(e) NA)
}

niches_means <- as.data.frame(a %>%
                    group_by(SP1) %>%
                          dplyr::summarise(mean.bio1 = mean(bio1),
                                           mean.bio2 = mean(bio2),
                                           mean.bio3 = mean(bio3),
                                           mean.bio4 = mean(bio4),
                                           mean.bio5 = mean(bio5),
                                           mean.bio6 = mean(bio6),
                                           mean.bio7 = mean(bio7),
                                           mean.bio12 = mean(bio12),
                                           mean.bio13 = mean(bio13),
                                           mean.bio14 = mean(bio14),
                                           mean.bio15 = mean(bio15),
                                           mean.cmimax = mean(cmimax),
                                           mean.cmimean = mean(cmimean),
                                           mean.cmimin = mean(cmimin),
                                           mean.cmirange = mean(cmirange),
                                           mean.gsl = mean(na.omit(gsl)),
                                           mean.gdd5 = mean(na.omit(gdd5)),
                                           mean.swb = mean(na.omit(swb)),
                                           mean.CCmean = mean(CCmean),
                                           mean.CCSD = mean(CCSD),

                                           sd.bio1 = sd(bio1),
                                           sd.bio2 = sd(bio2),
                                           sd.bio3 = sd(bio3),
                                           sd.bio4 = sd(bio4),
                                           sd.bio5 = sd(bio5),
                                           sd.bio6 = sd(bio6),
                                           sd.bio7 = sd(bio7),
                                           sd.bio12 = sd(bio12),
                                           sd.bio13 = sd(bio13),
                                           sd.bio14 = sd(bio14),
                                           sd.bio15 = sd(bio15),
                                           sd.cmimax = sd(cmimax),
                                           sd.cmimean = sd(cmimean),
                                           sd.cmimin = sd(cmimin),
                                           sd.cmirange = sd(cmirange),
                                           sd.gsl = sd(na.omit(gsl)),
                                           sd.gdd5 = sd(na.omit(gdd5)),
                                           sd.swb = sd(na.omit(swb)),
                                           sd.CCmean = sd(CCmean),
                                           sd.CCSD = sd(CCSD),
                                           
                                           median.bio1 = median(bio1),
                                           median.bio2 = median(bio2),
                                           median.bio3 = median(bio3),
                                           median.bio4 = median(bio4),
                                           median.bio5 = median(bio5),
                                           median.bio6 = median(bio6),
                                           median.bio7 = median(bio7),
                                           median.bio12 = median(bio12),
                                           median.bio13 = median(bio13),
                                           median.bio14 = median(bio14),
                                           median.bio15 = median(bio15),
                                           median.cmimax = median(cmimax),
                                           median.cmimean = median(cmimean),
                                           median.cmimin = median(cmimin),
                                           median.cmirange = median(cmirange),
                                           median.gsl = median(na.omit(gsl)),
                                           median.gdd5 = median(na.omit(gdd5)),
                                           median.swb = median(na.omit(swb)),
                                           median.CCmean = median(CCmean),
                                           median.CCSD = median(CCSD),
                                      
                                           shapiroP.bio1 = check_shapiro(bio1),
                                           shapiroP.bio2 = check_shapiro(bio2),
                                           shapiroP.bio3 = check_shapiro(bio3),
                                           shapiroP.bio4 = check_shapiro(bio4),
                                           shapiroP.bio6 = check_shapiro(bio6),
                                           shapiroP.bio7 = check_shapiro(bio7),
                                           shapiroP.bio12 = check_shapiro(bio12),
                                           shapiroP.bio13 = check_shapiro(bio13),
                                           shapiroP.bio14 = check_shapiro(bio14),
                                           shapiroP.bio15 = check_shapiro(bio15),
                                           shapiroP.cmimax = check_shapiro(cmimax),
                                           shapiroP.cmimean = check_shapiro(cmimean),
                                           shapiroP.cmimin = check_shapiro(cmimin),
                                           shapiroP.cmirange = check_shapiro(cmirange),
                                           shapiroP.gsl = check_shapiro(gsl),
                                           shapiroP.gdd5 = check_shapiro(gdd5),
                                           shapiroP.swb = check_shapiro(swb),
                                           shapiroP.CCmean = check_shapiro(CCmean),
                                           shapiroP.CCSD = check_shapiro(CCSD),

                                           skew.bio1 = skewness(bio1),
                                           skew.bio2 = skewness(bio2),
                                           skew.bio3 = skewness(bio3),
                                           skew.bio4 = skewness(bio4),
                                           skew.bio5 = skewness(bio5),
                                           skew.bio6 = skewness(bio6),
                                           skew.bio7 = skewness(bio7),
                                           skew.bio12 = skewness(bio12),
                                           skew.bio13 = skewness(bio13),
                                           skew.bio14 = skewness(bio14),
                                           skew.bio15 = skewness(bio15),
                                           skew.cmimax = skewness(cmimax),
                                           skew.cmimean = skewness(cmimean),
                                           skew.cmimin = skewness(cmimin),
                                           skew.cmirange = skewness(cmirange),
                                           skew.gsl = skewness(na.omit(gsl)),
                                           skew.gdd5 = skewness(na.omit(gdd5)),
                                           skew.swb = skewness(na.omit(swb)),
                                           skew.CCmean = skewness(CCmean),
                                           skew.CCSD = skewness(CCSD),
                              ))

niches_means$subClade<-"NA"
niches_means$PClade<-"NA"

for (name in clades$Species)
{
  niches_means$subClade[niches_means$SP1==name] = clades$clade[clades$Species==name] 
  niches_means$PClade[niches_means$SP1==name] = clades$PClade[clades$Species==name] 
}

write.csv(niches_means,"./inputs/inputClean/summaryClimValues.csv", row.names=FALSE)
