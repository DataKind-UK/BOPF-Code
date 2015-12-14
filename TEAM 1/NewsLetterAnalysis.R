# Load the data
setwd("~/DataDive/Newsletter Survey Data")
myData=read.csv(file="BOPF Newsletter Survey Data.csv", header=T)

# Re-order the values of these variables
myData$Q1_SocialContact=relevel(myData$Q1_SocialContact,"Strongly disagree")
myData$Q1_SocialContact=relevel(myData$Q1_SocialContact,"Disagree")
myData$Q1_SocialContact=relevel(myData$Q1_SocialContact,"Neither agree nor disagree")
myData$Q1_SocialContact=relevel(myData$Q1_SocialContact,"Tend to agree")
myData$Q1_SocialContact=relevel(myData$Q1_SocialContact,"Strongly agree")

myData$Q2_InfluenceDecisions=relevel(myData$Q2_InfluenceDecisions,"Strongly disagree")
myData$Q2_InfluenceDecisions=relevel(myData$Q2_InfluenceDecisions,"Disagree")
myData$Q2_InfluenceDecisions=relevel(myData$Q2_InfluenceDecisions,"Neither agree or disagree")
myData$Q2_InfluenceDecisions=relevel(myData$Q2_InfluenceDecisions,"Tend to agree")
myData$Q2_InfluenceDecisions=relevel(myData$Q2_InfluenceDecisions,"Strongly agree")

myData$Q3_ContribFreq=relevel(myData$Q3_ContribFreq,"Never")
myData$Q3_ContribFreq=relevel(myData$Q3_ContribFreq,"Once or twice")
myData$Q3_ContribFreq=relevel(myData$Q3_ContribFreq,"A few times")
myData$Q3_ContribFreq=relevel(myData$Q3_ContribFreq,"Every month")
myData$Q3_ContribFreq=relevel(myData$Q3_ContribFreq,"Most weeks")


## Create a new factor to collapse 55-64 and 64 - 74 due to such small numbers in the youngest age group
myData$Q5_AgeGroup <- factor(myData$Q5_AgeGroup, levels = c(levels(myData$Q5_AgeGroup), "55 - 74"))
myData$Q5_AgeGroup[myData$Q5_AgeGroup=="55 - 64"]<-"55 - 74"
myData$Q5_AgeGroup[myData$Q5_AgeGroup=="65 - 74"]<-"55 - 74"

## Re-order these levels
myData$Q5_AgeGroup=relevel(myData$Q5_AgeGroup,"85 and older")
myData$Q5_AgeGroup=relevel(myData$Q5_AgeGroup,"75 - 84")
myData$Q5_AgeGroup=relevel(myData$Q5_AgeGroup,"55 - 74")

# Set it again as a factor so unused levels will be deleted
myData$Q5_AgeGroup=factor(myData$Q5_AgeGroup)

# Get rid of incomplete cases so we don't plot any NAs in our plots
myData2=myData[complete.cases(myData$Q5_AgeGroup),]

# Plot Question 1

## First remove NAs
myData3=myData2[complete.cases(myData2$Q1_SocialContact),]

png('plot1c.png', width=789, height=597)
ggplot(myData3, aes(x = Q1_SocialContact))+geom_bar(aes(y = ..density..,group = Q5_AgeGroup,fill=factor(..x..)))+ facet_grid(Q5_AgeGroup~.) + theme(legend.position="none")+ggtitle("I have the amount and types of social contact I want")+xlab("Response")+ylab("Proportion")
dev.off()

# Plot Question 2
myData4=myData2[complete.cases(myData2$Q2_InfluenceDecisions),]
png('plot2.png', width=789, height=597)
ggplot(myData4, aes(x = Q2_InfluenceDecisions))+geom_bar(aes(y = ..density..,group = Q5_AgeGroup,fill=factor(..x..)))+ facet_grid(Q5_AgeGroup~.) + theme(legend.position="none")+ggtitle("I have the amount and types of social contact I want")+xlab("Response")+ylab("Proportion")+ggtitle("I can influence decisions that affect my local area, \n including how services are designed and delivered")
dev.off()

# Plot Question 3
myData5=myData2[complete.cases(myData2$Q3_ContribFreq),]
png('plot3.png', width=789, height=597)
ggplot(myData5, aes(x = Q3_ContribFreq))+geom_bar(aes(y = ..density..,group = Q5_AgeGroup,fill=factor(..x..)))+ facet_grid(Q5_AgeGroup~.) + theme(legend.position="none")+ggtitle("How often have you contributed to your community \n (through volunteering, belonging to a forum \nor steering group, or other activity) in the last 12 months?")+xlab("Response")+ylab("Proportion")
dev.off()

# Plot Question 6
summary(myData$Q6_Gender)
myData6=myData2[complete.cases(myData2$Q6_Gender),]
png('plot6.png', width=789, height=597)
ggplot(myData6, aes(x = Q6_Gender))+geom_bar(aes(y = ..density..,group = Q5_AgeGroup,fill=factor(..x..)))+ facet_grid(Q5_AgeGroup~.) + theme(legend.position="none")+ggtitle("What is your gender?")+xlab("Response")+ylab("Proportion")
dev.off()

# Didn't plot Q7 due to small number of responses

# Plot Question 17

levels(myData$Q17_Internet)
myData7=myData2[complete.cases(myData2$Q17_Internet),]
myData7$Q17_Internet=relevel(myData7$Q17_Internet,"No and I have no interest in doing do")
myData7$Q17_Internet=relevel(myData7$Q17_Internet,"No but I would like to")
myData7$Q17_Internet=relevel(myData7$Q17_Internet,"Yes but only do so weekly or less frequently")
myData7$Q17_Internet=relevel(myData7$Q17_Internet,"Yes and do so daily / more than once a week")
png('plot17.png', width=789, height=597)
ggplot(myData7, aes(x = Q17_Internet))+geom_bar(aes(y = ..density..,group = Q5_AgeGroup,fill=factor(..x..)))+ facet_grid(Q5_AgeGroup~.) + theme(legend.position="none")+ggtitle("Are you able to access the Internet?")+xlab("Response")+ylab("Proportion")
dev.off()

# Statistical test of the question "Is there any relationship between perceived influence and age?" Answer -  No!
library(ordinal)
summary(clm(Q2_InfluenceDecisions~Q5_AgeGroup, data=myData5))
names(myData)

# Testing how much correlation between social contact and perceived influence. Answer - a little.
library("polycor")
levels(myData$Q1_SocialContact)
levels(myData$Q2_InfluenceDecisions)
polychor(myData$Q1_SocialContact,myData$Q2_InfluenceDecisions)


##  Analysing those who do or do no feel like they have enough social contact, influence, and who do or do not volunteer
##  Done by transforming into binary variables
myData9=myData
myData9$ContactBin=as.numeric(myData9$Q1_SocialContact)
myData9=myData9[myData9$ContactBin!=3,]
myData9$ContactBin[myData9$ContactBin<3]=1
myData9$ContactBin[myData9$ContactBin>3]=0
myData9$ContactBin=factor(myData9$ContactBin)
summary(myData9$ContactBin)

## Here, I tried out multiple models, but the below contains all significant main effects I found

### age, gender, orientation, postcode, volunteering, influence, disability, ethnicity, religion, people in household, internet
summary(glm(ContactBin~Q10_Disabled+Q17_Internet+Q3_ContribFreq+Q14_NumHousehold, family="binomial", data=myData9))

## Do same for influence
myData10=myData[myData$Q2_InfluenceDecisions_!=3,]
myData10$InfluenceBin=NA
myData10$InfluenceBin[myData10$Q2_InfluenceDecisions_<3]=1
myData10$InfluenceBin[myData10$Q2_InfluenceDecisions_>3]=0
myData10$InfluenceBin=factor(myData10$Influence)

## Again, tried multiple models but this one only one containing significant factors
summary(glm(InfluenceBin~Q3_ContribFreq, family="binomial", data=myData10))
