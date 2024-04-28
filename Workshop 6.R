#Workshop 6 - Tidy data 2

#1. Introduction
#Last week, we encountered some instances where we might want to change what’s inside the cells. In today’s block we’re going to introduce a range of functions to clean, alter, and process data within your tables.
#We are making our data more tractable. Removing commas and values we don’t want, making sure what we have is consistent, and in the correct format.

#In this workshop were going to be using a new package, as well as tidyr, so lets read them both in now:
library(tidyr)
library(dplyr)
install.packages('dplyr')

#2. Select

beetles <- read.table("dung_beetles.csv", sep=",",header=T)
#Here when you click the link under 'Files', you can see that there is a load of extra commas at the end of each line
#R is creating columns we don’t need and giving them all default names. 

#To get rid of those, were going to do this with the ‘select’ function. 
#This is used to select certain columns and drop others
?select

#<tidy_select> is very flexible, so this can be numbers, names, or one of those helper functions.
#So if we wanted to pick out the species columns by number we could write:
beetles <- beetles %>% select(1:68)
#But this is clumsy and needs us to count all the columns. 

#There’s a few better ways we can solve this problem
beetles <-beetles %>% select(c(Month, Site, contains('_')))

#There is one more way to remove the extra columns - by using the negation operator '!'
#If you put this in front of any tidy-select command it will select everything except that. 
beetles <-beetles %>% select(!Month)
#So this will select every column except month

#3. Filter
#A convenient way to remove data from a dataset is using the filter function
#Provides a way to select subsets of rows 

# For example, say you wanted to remove rows (all sites) that were found to have less than 10 Onthophagus sideki. This could be achieved by this script:
beetles <-beetles %>% filter(Onthophagus_sideki > 10)

#You can combine columns too:
beetles %>% 
  filter(Onthophagus_sideki & Ochicanthon_woroae > 10)
#notice how the number of rows decreases (in comparison to when Onthophagus sideki was used alone)?

#Write you own script that selects only the row(s) for which Ochicanthon woroae has greater than 15 samples in the month of July
beetles <- beetles %>% 
  filter(Month == 'July') %>%
  filter(Ochicanthon_woroae >= 15)

#4. Rename
# ‘Copis’ should be ‘Copris’ and ‘Microcopis’ should be ‘Microcopris’

#We can do this individually by passing a named vector like this:
beetles %>% rename(c(Copris_agnus=Copis_agnus,
                     Copris_ramosiceps=Copis_ramosiceps,
                     ...))
#But that’s going to take a while

#There’s a tidy_select way to do this, use:
?rename
fixcopris <- function(x) {
  gsub("opis","opris",x)
}

#Now use what you find in the help file to apply this to the correct columns
#rename() changes the names of individual variables using new_name=old_name syntax
#but, rename_with() renames columns using a function
beetles %>% rename_with(fixcopris, matches("Copis"))  
# note how 'matches' is case insensitive, so it matches Copis and Microcopis 
# how would you change this to be case sensitive? 

#renaming and using pivot_longer
beetles <- beetles %>%
  select(!starts_with("X")) %>%
  rename_with(~ gsub("opis","opris",.x), matches("Copis")) %>% 
  pivot_longer(matches("_"),
               values_to = "count",
               names_to = "spp")

#beware of capitals
beetles %>% rename_with(tolower,everything())

#Mutate
#Mutate is a very powerful function. It can be used with any function that takes a vector, and returns a vector of the same length.
#Mutate will make a new column with the output of a function that we apply to a column. Like this:
mydf %>% mutate("new_column" = do_some_stuff(old_column) )
beetles %>% mutate("lower_month" = tolower(Month))

#Replacing values with Mutate
#This substituted _ to " " in the spp column
beetles %>% mutate("spp"=gsub("_"," ",spp))

#Let’s go back to the W.H.O. World Malaria Report. Read it in like you did last time, pivoting it to get the correct shape:
casesdf <- read.table("WMR2022_reported_cases_3.txt",
                      sep="\t",
                      header=T,
                      na.strings=c("")) %>% 
  fill(country) %>% 
  pivot_longer(cols=c(3:14),
               names_to="year",
               values_to="cases") %>%
  pivot_wider(names_from = method,
              values_from = cases)

#Those column names are going to be hard to work with, why not use what you learned above to rename them: “suspected”, “examined”, “positive”
?rename
casesdf <- casesdf %>% rename(c("suspected"="Suspected cases",
                     "examined" = "Microscopy examined",
                     "positive" = "Microscopy positive"))
str(casesdf,vec.len=2)

#Use mutate and gsub to remove the "X" from every value in the years column
casesdf <- casesdf %>% mutate(year = gsub("X", "", year))

#Change format with mutate
#We have removed 'X', but R still thinks this is a character vector, we need to explicitly change this to a numeric vector. The function 'as.numeric' will take the character vector and convert each one to a numerial value, you just need to figure out where to place it 
#update your previous function to both remove the ‘X’ and convert it to a numerical value - remember how you nest R functions within another
casesdf <- casesdf %>% mutate(year=as.numeric(gsub("X","",year)))

#mutate to remove all the numbers from the country column
casesdf <- casesdf %>% mutate(country = gsub("[0-9]", "", country))

#remove characters from number columns: 
casesdf <- casesdf %>% mutate("suspected"=as.numeric(gsub("[^0-9]","",suspected))) 

#This seems like something we’ll use again, why not make yourself a function which cleans numbers and casts them to a numerical value? call it ‘clean_number’
clean_number <- function(x) {as.numeric(gsub("[^0-9]","",x))}

#Mutate across
#the across function is designed tyo let you apply the same function to many different columns
?across
casesdf <- casesdf %>% mutate(across(c(suspected,examined,positive),clean_number))

#In fact if you look at the table you’ll see you could have just applied that clean_number function to everything except ‘country’.
#what is the alternative tidy_select way to select everything except ‘country’?
casesdf %>% mutate(across(!country,clean_number)) 

#calculations with mutate
casesdf <-casesdf %>% mutate(test_positivity = round(positive / examined,2)) 

#Factors
#Now that we’ve mutated every other column ‘country’ is starting to feel left out. Not to fear, we’ll mess with that next.
str(casesdf)
#If you look at the ‘str’ output for casesdf you’ll see that country is a character array. This is fine, but it is inefficient. We can instead convert it to a factor.
casesdf <- casesdf %>% mutate(country = as.factor(country)) 
levels(casesdf$country)
casesdf <- casesdf %>% 
  mutate(country = gsub("Eritrae",
                        "Eritrea",
                        country)) %>%
  mutate(country = as.factor(country)) 

#write to File
write.table(casesdf, "WMR2022_reported_cases_clean.txt",
            sep="\t",
            col.names = T,
            row.names = F,
            quote = F)

#The Big Challenge
#Write yourself a script that, from top to bottom, imports and cleans ‘WMR2022_reported_cases_3.txt’
#The script should:import, fill, pivot, rename columns, clean numerical columns, make a test positivity column, remove typos, remove footnote markers
clean_number <- function(x) {as.numeric(gsub("[^0-9]","",x))}

casesdf <- read.table("WMR2022_reported_cases_3.txt",
                      sep="\t",
                      header=T,
                      na.strings=c("")) %>% 
  fill(country) %>% 
  pivot_longer(cols=c(3:14),
               names_to="year",
               values_to="cases") %>%
  pivot_wider(names_from = method,
              values_from = cases) %>% 
  rename(c("suspected" = "Suspected cases",
           "examined" = "Microscopy examined",
           "positive" = "Microscopy positive")) %>% 
  mutate(year=as.numeric(gsub("X","",year))) %>% 
  mutate(across(c(suspected,
                  examined,
                  positive),clean_number)) %>% 
  mutate(test_positivity = round(positive / examined,2)) %>% 
  mutate(country = gsub("Eritrae",
                        "Eritrea",
                        country)) %>%
  mutate(country = as.factor(country)) 






