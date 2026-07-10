library(ggplot2)
library(ggpubr)
library(patchwork)

LocoSR<-read.csv("./inputs/inputRaw/locoRespectCheck.csv")

LocoSRA<-subset(LocoSR,Dataset !="MayBGI")
LocoSRA<-subset(LocoSR,Remove.!="Yes")

model<-lm(FCM~LocoGSE, data = LocoSRA)
model2<-lm(FCM~RESPECTSingle, data = LocoSRA)

LocoSRA2<-subset(LocoSRA,Ploidy==2)
model3<-lm(FCM~LocoGSE, data = LocoSRA2)
model4<-lm(FCM~RESPECTSingle, data = LocoSRA2)

par(mfrow=c(2,2))
plot(model)
plot(model2)
plot(model3)
plot(model4)

summary(model)
summary (model2)
summary (model3)
summary (model4)
confint(model)
confint(model2)
confint(model3)
confint(model4)

saveRDS(model, "./outputs/locoRespectComp/allLoco.rds")
saveRDS(model2, "./outputs/locoRespectComp/allRespect.rds")
saveRDS(model3, "./outputs/locoRespectComp/diploidLoco.rds")
saveRDS(model4, "./outputs/locoRespectComp/diploidRespect.rds")

Locoplot<-ggplot(LocoSRA,aes(y=FCM,x=LocoGSE,color=Level))+geom_smooth(method=lm,col="red")+geom_point()+geom_abline(intercept = 0, slope = 1,col="grey50")+theme_bw()+scale_y_continuous(limits=c(1,5),expand=c(0,0))+scale_x_continuous(limits=c(1,5),expand=c(0,0))+ylab("Genome Size, FCM (pg)\n")+xlab("Genome Size, LocoGSE (pg)")+scale_colour_viridis_d(begin = 0.1, end = 0.7)
Locoplot2<-ggplot(LocoSRA,aes(y=FCM,x=RESPECTSingle,color=Level))+geom_smooth(method=lm,col="red")+geom_point()+geom_abline(intercept = 0, slope = 1,col="grey50")+theme_bw()+scale_y_continuous(limits=c(0.5,14),expand=c(0,0))+scale_x_continuous(limits=c(0.5,14),expand=c(0,0))+ylab("Genome Size, FCM (pg)\n")+xlab("Genome Size, RESPECT (pg)")+scale_colour_viridis_d(begin = 0.1, end = 0.7)
Locoplot3<-ggplot(LocoSRA2,aes(y=FCM,x=LocoGSE,color=Level))+geom_smooth(method=lm,col="red")+geom_point()+geom_abline(intercept = 0, slope = 1,col="grey50")+theme_bw()+scale_y_continuous(limits=c(1,3),expand=c(0,0))+scale_x_continuous(limits=c(1,3),expand=c(0,0))+ylab("Genome Size, FCM (pg)\n")+xlab("Genome Size, LocoGSE (pg)")+scale_colour_viridis_d(begin = 0.1, end = 0.7)
Locoplot4<-ggplot(LocoSRA2,aes(y=FCM,x=RESPECTSingle,color=Level))+geom_smooth(method=lm,col="red")+geom_point()+geom_abline(intercept = 0, slope = 1,col="grey50")+theme_bw()+scale_y_continuous(limits=c(1,3.75),expand=c(0,0))+scale_x_continuous(limits=c(1,3.75),expand=c(0,0))+ylab("Genome Size, FCM (pg)\n")+xlab("Genome Size, RESPECT (pg)")+scale_colour_viridis_d(begin = 0.1, end = 0.7)

fig<-ggarrange(Locoplot,Locoplot2,Locoplot3,Locoplot4,ncol=2,nrow=2)
plot(fig)
ggsave(filename = "./outputs/figures/locoRespectCompLines.pdf", width = 12, height = 10, device = "pdf")
dev.off()

GSE<-read.csv("./inputs/inputRaw/locoRespectGSE.csv")
View(GSE)

plot<-ggplot(GSE, aes(x=factor(Clade, levels=c("Anarrhichomenum","Articulatum", "Basarthrum", "Herpystichum", "oxycoccoides","Pteroidea","Regmandra")), y=LocoGSE))
plot2<-ggplot(GSE, aes(x=factor(Clade, levels=c("Anarrhichomenum","Articulatum", "Basarthrum", "Herpystichum", "oxycoccoides","Pteroidea","Regmandra")), y=RESPECT))
plot<-plot+geom_boxplot()+xlab("\n")+ylab("2C Genome Size (pg)\n\n")+theme_bw(base_size=14)+scale_y_continuous(limits=c(0,4.7))+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))+theme(axis.text.x=element_blank())
plot2<-plot2+geom_boxplot()+xlab("Minor Clade")+ylab("2C Genome Size (pg)")+theme_bw(base_size=14)+scale_y_continuous(limits=c(0,4.7))+theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))

pdf(file="./outputs/figures/locoRespectBoxPlots.pdf", width=10,height=10)
plot/plot2 + plot_layout(axis_titles = "collect")

dev.off()
