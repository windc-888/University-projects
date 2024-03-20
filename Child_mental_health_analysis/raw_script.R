##LOADING REQUIRED PACKAGES##
library(tidyverse)
library(dplyr)
library(sf)
library(readxl)
library(gridExtra)
library(ggpubr)
library(car)
##

##IMPORTING & FORMATTING DATA##
filepath<-"datadownload.xlsx"
sheetnames<-excel_sheets(filepath)[6:11]
years<-c("2020","2019","2018","2017","2016","2015")


#For loop to cycle import all required sheets into separate data-frames
for( i in 1:length(sheetnames)){
  
  assign(sheetnames[i],
         read_excel(filepath,sheet = sheetnames[i],range=("A5:I346"))%>%
           select(!c(4:8))%>% #selecting only mental health column
           mutate(year=years[i])) #adding new column for year
  
}

#Merging all sheets into one tidy data-frame
health_data<-bind_rows(mget(sheetnames)) %>% 
  rename(score=`Children's social, emotional and mental health [Pe2]`,
         `Area Type` =`Area Type [Note 3]`)#renaming columns


#Subsetting only LTLA health data 
ltla_health<-health_data%>%
  filter(grepl("LTLA",`Area Type`))


#Creating non-tidy data frame
health_data_wider<-pivot_wider(health_data, 
                               names_from = year,
                               values_from = score)[,c(1,2,3,9,8,7,6,5,4)] #changing order of year columns
##

##IMPORTING SHAPEFILES & MERGING TO HEALTH DATA##
ltla_shape<-st_read("LAD_(Dec_2020)_UK_BFC.shp")%>%
  filter(grepl("E",LAD20CD)) #selecting only ltlas in england

#Checking for area codes in data file with no shapefile & excluding data with no shapefile
mismatch<-anti_join(ltla_health,ltla_shape,by=c("Area Code"="LAD20CD"))
mismatch<-unique(mismatch$`Area Code`) 

ltla_health_new<-filter(ltla_health,!grepl(mismatch[1],`Area Code`))%>%
  filter(!grepl(mismatch[2],`Area Code`))

#merging shapefile to health data
england<-full_join(ltla_shape,ltla_health_new,
                   by=c("LAD20CD"="Area Code"))

#Setting NA value as 0 in year column for areas with no health data
england$year[is.na(england$year)]<-"0"

england<-england%>%
  mutate(year=as.factor(year)) #setting year as factor

##

##CREATING SPATIAL PLOTS OVER TIME##
#For loop to create separate plots for each year
for (n in 1:length(years)){
  
  assign(paste0("p",n),
         
         filter(england,year==rev(years)[n]|year=="0")%>%
           ggplot()+
           geom_sf(aes(fill=score),color=NA)+
           scale_fill_viridis_c(option="A", limits=c(60,136),name="Mental health score")+
           ggtitle(rev(years)[n])+
           theme(plot.title = element_text(hjust = 0.5, face="bold"),
                 plot.margin = unit(c(0, 0, 0, 0), "pt"))
         
  )
  
}

#Arranging plots into one
spatial_plot<-ggarrange(p1,p2,p3,p4,p5,p6,ncol=3,nrow=2,common.legend=TRUE,legend = "right")

##

##CREATING BOXPLOTS
box_plot<-ggplot(ltla_health)+
  geom_boxplot(aes(x=as.factor(year),y=score,fill=as.factor(year)),
               width=0.5)+
                 scale_fill_brewer(palette = "BuPu")+
  theme(legend.position = "none")+
  ylab("Mental health score")+
  xlab("Year")+
  ggtitle("Distribution of mental health scores between 2015-2020")

##

##CREATING LINE PLOTS OVER TIME##
#Finding all region names + country 
region_names<-unique(health_data$`Area Name`[health_data$`Area Type` %in% c("Region","Country")])

#Creating colour pallete for line plot
pal<-c('black','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a')

#Plotting
line_plot<-filter(health_data,`Area Type`=="Region" | `Area Type` == "Country")%>%
  ggplot()+
  geom_line(aes(x=as.numeric(as.character(year)),y=score,color=`Area Name`),size=1.2)+
  scale_color_manual(values = pal,
                     limits = region_names)+
  ylim(85,105)+
  geom_hline(yintercept=100, linetype="dashed")+
  ggtitle("Mental health scores across England regions between 2015-2020")+
  ylab("Mental health score")+
  xlab("Year")

##

##STATISTICAL ANALYSIS##
#One-way ANOVA
res.aov <- aov(score ~ as.factor(year), data = ltla_health)
anova_result<-summary(res.aov)

#Pairwise t-test
pair_t<-pairwise.t.test(ltla_health$score,as.factor(ltla_health$year),
                p.adjust.method = 'BH')

#Checking assumptions of anova 
leveneTest(score ~ as.factor(year), data = ltla_health) #testing for homogeneity of variance
ggqqplot(ltla_health$score)#testing for normality

##
