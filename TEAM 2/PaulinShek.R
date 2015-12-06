dataPath <- "/home/paulin/Documents/DataKind/BOPF/BOPF-Data"

qol_data <- read.csv("/home/paulin/Desktop/Link to BOPF/BOPF-Data/Bristol_QoL_Survey/qol_2006-2014_clean.csv")

library(dplyr)



clipboard <- function(x, sep="\t", row.names=FALSE, col.names=TRUE){
  con <- pipe("xclip -selection clipboard -i", open="w")
  write.table(x, con, sep=sep, row.names=row.names, col.names=col.names)
  close(con)
}


temp <- qol_data %>% select(LSOA11_Code, U802)
temp$U802 <- as.logical(temp$U802)
write.csv(temp, file = "disableStopGoingOut.csv")
clipboard(temp)
View(head(qol_data))

#--------------------------------------------------------------------


library(treemap)
library(dplyr)

columns <- c("Q11_Deaf", "Q11_Hearing", "Q11_Learning", "Q11_MentalEmotional", 
             "Q11_LongTerm", "Q11_Physical", "Q11_Speech", "Q11_Visual")
df <- dat  %>% select(Q10_Disabled, starts_with("Q11_")) 
other <- df$Q11_Other
# treemap(df, c("Q11_Physical", 
#               "Q11_Hearing", 
#               "Q11_Deaf", "Q11_Learning", "Q11_MentalEmotional", 
#               "Q11_LongTerm", "Q11_Speech", "Q11_Visual"))


# how many disabilities? lowerbound?

library(ggplot2)
answered11 <- rowSums(select(df, one_of(columns)))>=1 | !is.na(df$Q11_Other)
answer10 <- df$Q10_Disabled
answer10 <- factor(answer10)
answer10 <- addNA(answer10)
answered <- data.frame(answer10, answered11)

g <- ggplot(data = answered, aes(x = answered11)) +
  geom_bar(aes(fill = answer10))
plot(g)

g <- ggplot(data = answered, aes(x = answer10)) +
  geom_bar(aes(fill = answered11)) + 
  ggtitle("Given answers for Q10, did respondents answer Q11?") + 
  ylab("Count") + 
  xlab("Question 10")
plot(g)
