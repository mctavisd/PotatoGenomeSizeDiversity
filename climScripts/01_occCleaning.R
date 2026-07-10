# 01_occCleaning: remove uncertain or duplicate occurrence records from occurrence dataset
# Jun 2026

# Adapted from "001_Cleaning_AustraliaVirtHerb.R", E. Gagnon

library(geodata)
library(raster)
library(dplyr)
library(sp)
library(terra)
library(ggplot2)
library(CoordinateCleaner)

# Checked for missing coordinate data, manually deleted occurrences without lat/long

# Import raw data:
mergeOcc<-read.csv("./inputs/inputRaw/mergeOcc.csv")

###############################################################################
# Filtering steps before coordinateCleaner:

# Remove species for which we have no genome size data:
#####
speciesList<-read.csv("./inputs/filterFiles/speciesList.csv")

# Remove occurrences for species not in the list of species with available material:
mergeOcc[mergeOcc$SP1%in%speciesList$SP1,]->mo2
table(mo2$SP1)
mergeOcc<-mo2
dim(mergeOcc) # 18056 occs
#######

# Removing imprecise coordinates (lat/long values with less than 2 decimal points)
#####
mergeOcc$LATDEC<-as.numeric(mergeOcc$LATDEC)
mergeOcc$LONGDEC<-as.numeric(mergeOcc$LONGDEC)
mergeOcc<-subset(mergeOcc,(LATDEC*100)%%10!=0 | (LONGDEC*100)%%10!=0)
dim(mergeOcc) #17687 occs
#######

# Check for wrong country:
#####
world(path=tempdir())->World
sworld<-sf::st_as_sf(World)
World<-as(sworld,"Spatial")

# Ignore any occurrences from Särkinen dataset, they have no country data:
subset(mergeOcc,mergeOcc$Source=="GagnOl" | mergeOcc$Source== "Potato")->data2

as.numeric(data2$LONGDEC)->data2$LONGDEC
as.numeric(data2$LATDEC)->data2$LATDEC
coordinates(data2)<-~LONGDEC+LATDEC
crs(data2)<-crs(World)

# Check which countries occurrences fall into on world map:
ovr <- over(data2, World)
colnames(ovr)
cntr<-ovr$NAME_0

# Store index values of occs whose listed country doesn't match the one they fell into on world map:
j <-which((cntr) != as.vector(data2$COUNTRY))
print(j) # Gives row numbers of occs mismatched countries

length(j) # Gives number of coordinates which don't fall in the right country
# 12 occs

# Reset data2 to get readable rows, then print mismatched occs:
subset(mergeOcc,mergeOcc$Source=="GagnOl" | mergeOcc$Source== "Potato")->data2
print(data2[c(957, 1942, 2337, 3402, 3625, 4084, 5790, 6779, 7172, 8276, 8497, 9057),])
# All of these are on the border or actually in the right country when coordinates are checked manually; keep them

#######
# Check if occs are in the ocean:
#####
data.coord <- mergeOcc %>%
  dplyr::select(SP1, LATDEC, LONGDEC, COUNTRY)

data.coord[,2]<-as.numeric(data.coord[,2])

# Create an object of class "SpatialPoints" with the geographic coordinates of the specimens
data.coord.spatial <- SpatialPoints(data.coord[,3:2], proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs"))

predictors.bio1 <- raster("./inputs/chelsa/CHELSA_cmimean_1981-2010_V.2.1.tif") #selects Bio1 file

# Plot the mask
plot(predictors.bio1, useRaster=T, legend=F)
plot(data.coord.spatial, add=T, pch=19, cex=0.2, col="red")
axis(1)
mtext(side=1, "Longitude (degrees)", cex=1.5, line=3)

axis(2)
mtext(side=2, "Latitude (degrees)", cex=1.5, line=3)

# Extract the values of the mask at the coordinates of the specimen records
data.coord.land <- extract(predictors.bio1, data.coord[,3:2], method='simple')

class(data.coord.land)
summary(data.coord.land)
sum(is.na(data.coord.land)) # Number of specimens falling outside the mask (in the ocean): 0

sum(!is.na(data.coord.land)) # Number of specimens falling inside the mask (on land): 17687
#######

#Extra steps if ocean points found (not required):
#####
#plot the mask and specimens that fall off the mask
#plot(predictors.bio1, col="gray90", useRaster=T, legend=F)
#plot(data.coord.spatial[which(is.na(data.coord.land))], add=T, pch=19, cex=0.2, col="blue")
#points(data.coord[which(is.na(data.coord.land)),3:2], pch=19, cex=0.5, col="red")
#mtext(side=1, "Longitude (degrees)", cex=1.5, line=3)
#mtext(side=2, "Latitude (degrees)", cex=1.5, line=3)

#class(data.coord.land)
#length(data.coord.land) #17687

#flags.pushback<- data.frame(mergeOcc[which(is.na(data.coord.land)),])
#length(data.coord.land)
#dim(flags.pushback)
#head(flags.pushback)
#table(flags.pushback$species)
#table(flags.pushback$country)

#write.csv(flags.pushback, file="./flags/flags_pushback_ocean.csv")
#data.pushback<- mergeOcc[!mergeOcc$ACCESSION %in% flags.pushback$ACCESSION,]
#data<-data.pushback
#dim(data.pushback) #0
#length(unique(data.pushback$species)) #0
#plot(wrld_simpl)
#points(flags.pushback$long,flags.pushback$lat,col="red",pch=20,cex=0.75)
#dev.off()
#######

###############################################################################
# CoordinateCleaner

# Preparing for filtering:
#####
#select columns of interest for filtering; data3 will be run through the filters:
data3 <- mergeOcc %>%
  dplyr::select(SP1,LATDEC, LONGDEC, ACCESSION, MASTER)

dim(data3)# 17687

#Plot data to get an overview:
wm <- annotation_borders("world", colour="gray50", fill="gray50")
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = data3, aes(x = LONGDEC, y = LATDEC),
             colour = "darkred", size = 0.5)+
  theme_bw()
plot

# To avoid specifying it in each function, change the name of lat long:
names(data3)[2:3] <- c("decimalLatitude", "decimalLongitude")
#######

# Filtering steps:

# Points that are not valid (impossible coordinates)
#####
clean_val<-data.frame(SP1=data3$SP1,decimalLatitude=data3$decimalLatitude,decimalLongitude=data3$decimalLongitude,MASTER=data3$MASTER)
#View(clean_val)

clean_val <- data3%>%cc_val()

#Store occs caught by filter in val:
mergeOcc[!data3$MASTER%in%clean_val$MASTER,]->val
dim(val)# 0 found, no invalid occs

#######

# Equivalent lon & lat
#####
clean_equ <- data3 %>% cc_equ() # 0 occs

mergeOcc[!data3$ACCESSION%in%clean_equ$ACCESSION,]->equ
dim(equ) # 0 found
#######

# Points that fall near the gbif institution
#####
clean_gbif <- data3%>%
  cc_gbif() # 0 found

mergeOcc[!data3$ACCESSION%in%clean_gbif$ACCESSION,]->gbif
dim(gbif)
#######

#Points that fall near gardens and other institutions
#####
clean_inst <- data3%>%
  cc_inst() # 1 occurrence

mergeOcc[!data3$MASTER%in%clean_inst$MASTER,]->inst

# Save map and list of flagged occurrences:
wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mergeOcc, colour="black", cex=0.5, aes(x = LONGDEC, y = LATDEC))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  geom_point(data = inst, colour="red", cex = 0.5, aes(x = LONGDEC, y = LATDEC))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))

ggsave(filename = "./outputs/flags/Solanum_inst_flag.pdf", width = 10, height = 5, device = "pdf")
dev.off()

write.csv(inst,file="./outputs/flags/Solanum_inst_flag.csv",row.names=FALSE)
#######

#Points that are zero longitude and zero latitude and a radium around the zero lon and zero lat
#####
clean_zero <- data3%>%
  cc_zero() # 0 occs

mergeOcc[!data3$MASTER%in%clean_zero$MASTER,]->zero
dim(zero)
#######

#Points that fall into centroids
#####
clean_cen <- data3%>%
  cc_cen()

mergeOcc[!data3$MASTER%in%clean_cen$MASTER,]->cen
dim(cen) # 8 occs

wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mergeOcc, colour="black", cex=0.5, aes(x = LONGDEC, y = LATDEC))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  geom_point(data = cen, colour="red", cex = 0.5, aes(x = LONGDEC, y = LATDEC))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))

ggsave(filename = "./outputs/flags/Solanum_cen_flag.pdf", width = 10, height = 5, device = "pdf")
dev.off()

write.csv(cen,file="./outputs/flags/Solanum_cen_flag.csv", row.names=FALSE)
#######

#Points that fall into capitals, within a 10 km radius from centroid
#####
clean_cap <- data3%>%
  cc_cap() # 14 occs

mergeOcc[!data3$MASTER%in%clean_cap$MASTER,]->cap

wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mergeOcc, colour="black", cex=0.5, aes(x = LONGDEC, y = LATDEC))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  geom_point(data = cap, colour="red", cex = 0.5, aes(x = LONGDEC, y = LATDEC))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))

ggsave(filename = "./outputs/flags/Solanum_cap_flag.pdf", width = 10, height = 5, device = "pdf")
dev.off()

write.csv(cap,file="./outputs/flags/Solanum_cap_flag.csv", row.names=FALSE)
#######

#Outliers - get rid of outliers for species with at least 7 occurrences
#####
clean_outl <- (data3)%>%
  cc_outl(.,species="SP1") # Removes 141 occs

mergeOcc[!data3$MASTER%in%clean_outl$MASTER,]->outl

wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mergeOcc, colour="black", cex=0.5, aes(x = LONGDEC, y = LATDEC))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  geom_point(data = outl, colour="red", cex = 0.5, aes(x = LONGDEC, y = LATDEC))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))

ggsave(filename = "./outputs/flags/Solanum_outl_flag.pdf", width = 10, height = 5, device = "pdf")
dev.off()

write.csv(cap,file="./outputs/flags/Solanum_outl_flag.csv", row.names=FALSE)
#######

# Removing duplicate occurrences
#####
clean_dupl <- data3%>%
  cc_dupl(.,species="SP1")
#Removes 9847 occs

mergeOcc[!data3$MASTER%in%clean_dupl$MASTER,]->dupl
dim(dupl)

wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
plot<-ggplot()+ coord_fixed()+ wm +
  geom_point(data = mergeOcc, colour="black", cex=0.5, aes(x = LONGDEC, y = LATDEC))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  geom_point(data = dupl, colour="red", cex = 0.005,shape=1, aes(x = LONGDEC, y = LATDEC))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))

ggsave(filename = "./outputs/flags/Solanum_dupl_flag.pdf", width = 10, height = 5, device = "pdf")
dev.off()

write.csv(dupl,file="./outputs/flags/Solanum_dupl_flag.csv", row.names=FALSE)
#######

#Removing occurrences outside of general species range not caught by cc_outl:
#####
oddOccs<-read.csv("./inputs/filterFiles/occsToRemove.csv")
View(oddOccs)
dim(mergeOcc)
mergeOcc<-mergeOcc[!mergeOcc$MASTER%in%oddOccs$MASTER,]
#######

# Combining clean datasets from each filtering step, saving progress:
#####

toto<-mergeOcc[mergeOcc$MASTER%in%clean_dupl$MASTER,]
toto<-toto[toto$MASTER%in%clean_cen$MASTER,]
toto<-toto[toto$MASTER%in%clean_cap$MASTER,]
toto<-toto[toto$MASTER%in%clean_val$MASTER,]
toto<-toto[toto$MASTER%in%clean_equ$MASTER,]
toto<-toto[toto$MASTER%in%clean_gbif$MASTER,]
toto<-toto[toto$MASTER%in%clean_zero$MASTER,]
dim(toto)

mergeOcc<-toto
dim(mergeOcc) # 7817 occs

# Remove outliers separately:

toto<-toto[toto$MASTER%in%clean_outl$MASTER,]
Xoutl<-toto

#remove species with 1 occurrence
one<-mergeOcc %>% group_by(SP1)%>%filter(n()>1)
dim(one) # 7815

mergeOcc[!mergeOcc$MASTER%in%one$MASTER,]->one
mergeOcc<-mergeOcc %>% group_by(SP1)%>%filter(n()>1)

oneX<-Xoutl %>% group_by(SP1)%>%filter(n()>1)
Xoutl[!Xoutl$MASTER%in%oneX$MASTER,]->oneX
Xoutl<-Xoutl %>% group_by(SP1)%>%filter(n()>1)

write.csv(mergeOcc,file="./inputs/inputClean/cleanData.csv", row.names=FALSE)
write.csv(Xoutl,file="./inputs/inputClean/cleanData_xoutl.csv", row.names=FALSE)

#######

#Keeping outliers for keeper species (species with occs trimmed by cc_outl unnecessarily):
#####
keepOutl<-read.csv("./inputs/filterFiles/keepOutl.csv")
keepers<-subset(mergeOcc,SP1%in%keepOutl$SP1)
table(keepers$SP1)

xOutliers<-subset(Xoutl,!Xoutl$SP1%in%keepOutl$SP1)
clean<-rbind(keepers,xOutliers)

#######

#Taking ploidy level into account:
#####

#Get list of species with multiple cytotypes:
cytotypes<-read.csv("./inputs/filterFiles/cytotypes.csv")
multiPloidy<-subset(cytotypes,Multiple.=="Y")

multiSol<-subset(clean, SP1%in%multiPloidy$Species)
multiSol<-subset(multiSol,!is.na(multiSol$Ploidy))
multiSol$SP1<-paste(multiSol$SP1,multiSol$Ploidy,sep="_")

clean<-subset(clean,!SP1%in%multiPloidy$Species)
clean<-rbind(multiSol,clean)
dim(clean) # 5472 occs total
table(clean$SP1)

#dim(subset(backup,SP1%in%multiPloidy$Species))
dim(multiSol) # 1066 occs from species with multiple ploidy levels
#######

#Final Step for Cleaning:
#####
dim(clean) #5472 occurrences

write.csv(clean,file="./inputs/inputClean/cleanDataPreSpatial.csv", row.names=FALSE)
#######

#Spatial Filtering:
#Code taken from 003_Spatial_filtering_scripts_SOLANUM:
#####
# This is the function itself
filterByProximity <- function(xy, dist, mapUnits = F) {
  #xy can be either a SpatialPoints or SPDF object, or a matrix
  #dist is in km if mapUnits=F, in mapUnits otherwise
  if (!mapUnits) {
    d <- spDists(xy,longlat=T)
  }
  if (mapUnits) {
    d <- spDists(xy,longlat=F)
  }
  diag(d) <- NA
  close <- (d <= dist)
  diag(close) <- NA
  closePts <- which(close,arr.ind=T)
  discard <- matrix(nrow=2,ncol=2)
  if (nrow(closePts) > 0) {
    while (nrow(closePts) > 0) {
      if ((!paste(closePts[1,1],closePts[1,2],sep='_') %in% paste(discard[,1],discard[,2],sep='_')) & (!paste(closePts[1,2],closePts[1,1],sep='_') %in% paste(discard[,1],discard[,2],sep='_'))) {
        discard <- rbind(discard, closePts[1,])
        closePts <- closePts[-union(which(closePts[,1] == closePts[1,1]), which(closePts[,2] == closePts[1,1])),]
      }
    }
    discard <- discard[complete.cases(discard),]
    discard <- as.matrix(discard)
    return(xy[-discard[,1],])
    #return <- discard
  }
  if (nrow(closePts) == 0) {
    return(xy)
    #return <- discard
  }
  return(return)
}

#Load the appropriate dataset:
df<-read.csv("./inputs/inputClean/cleanDataPreSpatial.csv")

colnames(df)
dim(df) # 5472 occs
table(df$SP1)
names.list<-unique((df$SP1))
length(names.list)

# Prior to filtering, remove duplicate coordinates within each species; already done by cc

# This next section is when we will start to do spatial filtering
# The next few lines set up the objects needed to run the script.

occurrence.records<-c()
df.results<-c()
number.records<-c()
# as.matrix(number.records)
list1<-c() # Contains all the species that have more than 5 occurrence points, and that have lost some records, but still more than 5
list2<-c() # Contains all species that originally had less than 5 occurrence points
list3<-c() # Contains all species that originally had more than 5 occurrence points, but now have less than five.

sink("./outputs/occCleaning/spatial_filtering_results.csv")

for (i in names.list)
{
  print(names.list[i])
  occurrence.records[[i]]<-df[df$SP1 %in% i,]
  number.records[i]<-dim(occurrence.records[[i]])[1]
  
  #This writes a table of occurence data for each species
  name<-paste("./outputs/occCleaning/preSpatialfilterOccs/",i,"occurrence_data.csv",sep="_")
  write.csv(df[grepl(i,df$SP1),], file=name)
  
  
  toto<-df[df$SP1 %in% i,]
  print(paste(i,"is a matrix of", dim(toto)[1],"occurence records",sep=" "))  
  # Set the distance over which to preform Spatial Filtering in km
  scale_distance <- 10
  
  # This object should be coordinates for your species/group in decimal degrees
  species_data<-(toto[,8:9])
  print(dim(species_data))
  
  # This is how you run the function
  results<-filterByProximity(data.matrix(species_data), scale_distance, mapUnits=F)
  if (inherits(results, "matrix"))
  {print(paste("There is a difference of ", length(species_data[,1])-length(results[,1])," between the two datasets.", sep=""))
  }else
  {print(paste("There is a difference of ", length(species_data[1])-length(results[1])," between the two datasets.", sep=""))
  }
  
  if (length(results)>=10)
  {print("More than five occurence points retained")
    toto2<-df[rownames(results),]
    df.results<-rbind(df.results,toto2)
    print(paste("df.results now has",dim(df.results)[1],"rows, and", dim(df.results)[2],"columns",sep=" "))
    if(length(species_data[,1])-length(results[,1]!=0))
    {list1[i]<-i
    }
  } else
    
  {
    
    if (length(species_data)<10)
    {df.results<-rbind(df.results,toto)
    print("Original dataset had less than five occurence points retained")
    print(paste("df.results now has",dim(df.results)[1],"rows, and", dim(df.results)[2],"columns",sep=" "))
    list2[i]<-i
    }else
    {df.results<-rbind(df.results,toto)
    print("Original dataset had at least five occurence points, but less than five retained")
    print(paste("df.results now has",dim(df.results)[1],"rows, and", dim(df.results)[2],"columns",sep=" "))
    list3[i]<-i
    }
  }
  gc()
  
}

sink()

dim(df)
dim(df.results) # 4153 from 5472

write.csv(df.results,"./inputs/inputClean/DF_results_all_spatial_filtering.csv", row.names=FALSE)

length(list1) #57
length(list2) #22
length(list3) #0

#######

#Making Maps:
#####
mapRaw<-read.csv("./inputs/inputClean/DF_results_all_spatial_filtering.csv")
sol.names<-unique(mapRaw$SP1)

checkTab<-table(mapRaw$SP1)

number.records<-matrix(,nrow=length(unique(mapRaw$SP1)),ncol=2)
rownames(number.records)<-unique(mapRaw$SP1)
mapRaw$Source<-factor(mapRaw$Source)
occurrence.records<-list()
table(mapRaw$Source)
for (i in sol.names)
{
  occurrence.records[[i]]<-mapRaw[grepl(i,mapRaw$SP1),]
  #This writes a table of occurence data for each species
  name<-paste("./outputs/occCleaning/occBySpecies/data/",i,"occurrence_data.csv",sep="_")
  write.csv(mapRaw[grepl(i,mapRaw$SP1),], file=name)
  palette()
  #This produces a map for each species
  mapRaw[grepl(i,mapRaw$SP1),]->toto
  name.map<-paste("./outputs/occCleaning/occBySpecies/maps/",i,"occurrence_data.pdf",sep="_")
  
  wm <- annotation_borders("world", colour = "black", fill="white",lwd=0.1)
  
  if (i=="acroscopicum"|name=="andreanum"|name=="brevicaule"|name=="stoloniferum")
  {
    plot<-ggplot()+ coord_fixed()+ wm + coord_sf(xlim=c(-115,-55), ylim = c(-45,40))+
    geom_point(data = toto, cex=0.5, aes(x = LONGDEC, y = LATDEC, colour = Ploidy))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))
    ggsave(filename = name.map, width = 10, height = 5, device = "pdf")
  }
  else
  {
    plot<-ggplot()+ coord_fixed()+ wm + coord_sf(xlim=c(-115,-55), ylim = c(-45,40))+
    geom_point(data = toto, cex=0.5, aes(x = LONGDEC, y = LATDEC, colour = Ploidy))+theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),legend.position="none")
    plot+ylab("Latitude")+xlab("Longitude")+theme(legend.text = element_text(size = 10))
    ggsave(filename = name.map, width = 10, height = 5, device = "pdf")   
    
  }
  
  print(dim(occurrence.records[[i]]))
  
  dim(occurrence.records[[i]])->number.records[i,]
}
dev.off()
