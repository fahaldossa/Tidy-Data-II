#Workshop 6 - Tidy data 2

#1. Introduction
#Last week, we encountered some instances where we might want to change what’s inside the cells. In today’s block we’re going to introduce a range of functions to clean, alter, and process data within your tables.
#We are making our data more tractable. Removing commas and values we don’t want, making sure what we have is consistent, and in the correct format.

#In this workshop were going to be using a new package, as well as tidyr, so lets read them both in now:
library(tidyr)
library(dplyr)

#2. Select

beetles <- read.table("dung_beetles.csv", sep=",",header=T)
#Here when you click the link under 'Files', you can see that there is a load of extra commas at the end of each line
#R is creating columns we don’t need and giving them all default names. 

#To get rid of those, were going to do this with the ‘select’ function. 
#This is used to select certain columns and drop others
?select

#<tidy_select> is very flexible, so this can be numbers, names, or one of those helper functions.
#So if we wanted to pick out the species columns by number we could write:
beetles %>% select(1:68)
#But this is clumsy and needs us to count all the columns. 

#There’s a few better ways we can solve this problem
beetles %>% select(c(Month, Site, contains('_')))

#There is one more way to remove the extra columns - by using the negation operator '!'
#If you put this in front of any tidy-select command it will select everything except that. 
beetles %>% select(!Month)
#So this will select every column except month

#3. Filter
#A convenient way to remove data from a dataset is using the filter function
#Provides a way to select subsets of rows 

# For example, say you wanted to remove rows (all sites) that were found to have less than 10 Onthophagus sideki. This could be achieved by this script:
beetles %>% filter(Onthophagus_sideki > 10)

#You can combine columns too:
beetles %>% 
  filter(Onthophagus_sideki & Ochicanthon_woroae > 10)








