# 04_NicheAssign: Script for calculating climatic niche breadth variables
# June 2026, Delaney McTavish-McHugh, mctavisd@uoguelph.ca

library(dplyr)

solMap<-read.csv("./inputs/inputClean/summaryClimValues.csv")
a <- read.csv("./inputs/inputClean/climateOccsWithSpecies.csv")

b <- as.data.frame(a %>%
                     group_by(SP1) %>%
                     dplyr::summarise(Specimens = n()))

#Function for calculating range realized /range available:
prop.climrange <- function(x,y) {  
  (max(x) - min(x))/y
}

sp_u10 <-dplyr::filter(a, Specimens < 10)
sp_o10 <-dplyr::filter(a, Specimens >= 10)
spfilt_u10 <-dplyr::filter(a, SP1 %in% sp_u10$SP1)
spfilt_o10 <-dplyr::filter(a, SP1 %in% sp_o10$SP1)

# prop. niche with PCA chosen layers 
# for species below 10 records:
niches_u10 <- as.data.frame(spfilt_u10 %>%
                              group_by(SP1) %>%
                              dplyr::summarise(niche.bio1me = prop.climrange(bio1,range.bio1[1]),
                                               niche.bio2me = prop.climrange(bio2,range.bio2[1]),
                                               niche.bio4me = prop.climrange(bio4,range.bio4[1]),
                                               niche.bio12me = prop.climrange(bio12,range.bio12[1]),
                                               niche.bio15me = prop.climrange(bio15,range.bio15[1]),
                              ))

#subsampling for species with >= 10 records: 
list <- list()
for (i in 1:1000) {
  list[[i]] <-as.data.frame(spfilt_o10 %>%
                              group_by(SP1) %>% 
                              sample_frac(0.5) %>% 
                              dplyr::summarise(niche.bio1m = prop.climrange(bio1,range.bio1[1]),
                                               niche.bio2m = prop.climrange(bio2,range.bio2[1]),
                                               niche.bio4m = prop.climrange(bio4,range.bio4[1]),
                                               niche.bio12m = prop.climrange(bio12,range.bio12[1]),
                                               niche.bio15m = prop.climrange(bio15,range.bio15[1]),
                              ))
}

data_out <- as.data.frame(do.call(rbind, list))

niches_o10 <-as.data.frame(data_out %>%
                             group_by(SP1) %>% 
                             dplyr::summarise(
                               niche.bio1me = mean(niche.bio1m),
                               niche.bio2me = mean(niche.bio2m),
                               niche.bio4me = mean(niche.bio4m),
                               niche.bio12me = mean(niche.bio12m),
                               niche.bio15me = mean(niche.bio15m),
                             ))

niches_o10_un <- niches_o10 %>%  distinct()

# merging
niches <- niches_o10

# merging
niches_un <- niches_o10_un
niches<- rbind(niches_o10,niches_u10)

write.table(niches,file="./outputs/climate/niche_ranges.csv",sep=";")

##############################
# merging with dataset with specimen counts
niches <- niches[with(niches, order(niches$SP1)), ]
niches_perspecies <- inner_join(niches, b, by = "SP1")

# calculating breadth
niches_perspecies$breadth <- NA
for (i in 1:length(niches_perspecies$SP1)){
  niches_perspecies$breadth[i] <- sum(niches_perspecies[i,2:6])
}

niches_perspecies_un<-unique(niches_perspecies)

niches_perspecies_un$logbreadth<-log(niches_perspecies_un$breadth)
niches_perspecies_un$sqrbreadth<-sqrt(niches_perspecies_un$breadth)
niches_perspecies_un<-cbind(niches_perspecies_un,solMap[,c(2:3,5,9,12,101:102)])

dim(niches_perspecies_un)#100

toto2<-niches_perspecies_un

#Re-add genome size estimates:
toto2$genomeSize<-"NA"
toto2$genomeSizeMethod<-"NA"
toto2$Ploidy<-"NA"
toto2$gsMono<-"NA"

FCM<-read.csv("./inputs/filterFiles/FCM.csv")

for (name in FCM$Species)
{
  toto2$genomeSizeMethod[toto2$SP1==name] = "FCM"
  toto2$genomeSize[toto2$SP1==name] = FCM$genomeSize[FCM$Species==name] 
  toto2$Ploidy[toto2$SP1==name] = FCM$ChrNumber[FCM$Species==name]/12
}

#######

# Assigning LocoGSE Genome Sizes to occurrences:
#####
Loco<-read.csv("./inputs/filterFiles/LocoGSE.csv")

for (name in Loco$Species)
{
  toto2$genomeSizeMethod[toto2$SP1==name] = "LocoGSE"
  toto2$genomeSize[toto2$SP1==name] = Loco$genomeSize[Loco$Species==name] 
  toto2$Ploidy[toto2$SP1==name] = as.numeric(Loco$ChrNumber[Loco$Species==name])/12
}
#######

toto2$genomeSize = as.numeric(toto2$genomeSize)
toto2$Ploidy = as.numeric(toto2$Ploidy)
toto2$gsMono = toto2$genomeSize/toto2$Ploidy
toto2$Ploidy[toto2$Ploidy==2] = "Diploid"
toto2$Ploidy[toto2$Ploidy==4] = "Tetraploid"
toto2$Ploidy[toto2$Ploidy==6] = "Hexaploid"

write.csv(toto2,"./inputs/inputClean/nicheMeanSummary.csv", row.names=FALSE)

#####
