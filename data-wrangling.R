library(tidyverse)
library(stringr)

## Data Wrangling

#### Clustering Data - IPEDS ####

# data source: Integrated Postsecondary Education Data System (IPEDS), 2017-2022, Amherst College: Completions
# https://nces.ed.gov/ipeds/datacenter/FacsimileView.aspx?surveyNumber=3&unitId=164465&year=2020

# read-in data IPEDS data 
degrees18 <- read_csv("data/degrees_2018.csv")
degrees19 <- read_csv("data/degrees_2019.csv")
degrees20 <- read_csv("data/degrees_2020.csv")
degrees21 <- read_csv("data/degrees_2021.csv") 
degrees22 <- read_csv("data/degrees_2022.csv") 
degree_df <- read_csv("data/ZhuSData.csv")

## 1. extract data from messy csv format

# create function to clean data from IPEDS website (data was copy and pasted into excel)
clean <- function(df, data_year){
  
  dg <- df %>% select(-15)
  names(dg) <- c('code', 'major', 'level', 'gender','nonresident', 
                 'hispanic_latino', 'native', 'asian', 'black', 'hawaiian', 
                 'white', 'two_race', 'unknown_race', 'total')
  
  # begin cleaning data by extracting cols and rows
  majors <- dg[is.na(dg$gender), c(1)] %>% filter(!is.na(code))
  men <- dg[grepl('[0-9]', dg$code), -c(1:3)]
  women <- dg[dg$code == 'Women', -c(12:14)] %>% filter(!is.na(code))
  names(women) <- c('gender', 'nonresident', 'hispanic_latino', 'native', 
                    'asian', 'black', 'hawaiian', 'white', 'two_race', 'unknown_race', 'total')
  total <- dg[dg$code == 'Total', -c(12:14)] %>% filter(!is.na(code))
  names(total) <- c('gender', 'nonresident', 'hispanic_latino', 'native', 
                    'asian', 'black', 'hawaiian', 'white', 'two_race', 'unknown_race', 'total')
  
  # create data frame with reformatted columns
  df1 <- data.frame(majors, total, male = men$total) %>% 
    # remove gender column
    select(-gender) %>% 
    # group by major and sum degrees for each demographic category
    group_by(code) %>% 
    summarise(nonresident = sum(as.numeric(nonresident)),
              across(2:11, ~ sum(as.numeric(.x)))) %>% 
    # relocate columns
    relocate(total, .before = nonresident) %>% 
    relocate(male, .before = nonresident) 
  
  # add info from male df
  df2 <- data.frame(majors, men) %>% 
    select(-gender) %>% 
    group_by(code) %>% 
    summarise(nonresident = sum(as.numeric(nonresident)),
              across(2:10, ~ sum(as.numeric(.x)))) %>% 
    relocate(total, .before = nonresident) 
  
  # Native Alaskan/Indian American, Hawaiian/Pacific Islander, Unknown Race, and 2+ Races 
  # only make up 0, 0, 2.7, and 5 percent of the sample population, respectively.
  # Remove these variables so they don't skew the final clustering solution.
df3 <- df1 %>% 
  left_join(select(df2, c(code, native_m = native, hawaiian_m = hawaiian, 
                          unknown_m = unknown_race, two_race_m = two_race)), by = 'code') %>% 
  mutate(male = male - (native_m + hawaiian_m + unknown_m + two_race_m),
         total = total - (native + hawaiian + unknown_race + two_race)) %>% 
  select(-c(native, hawaiian, unknown_race, two_race, native_m, 
            hawaiian_m, unknown_m, two_race_m)) %>% 
  mutate(year = data_year)

return(df3)
}

# clean data sets for each year
df18 <- clean(degrees18, 18)
df19 <- clean(degrees19, 19)
df20 <- clean(degrees20, 20)
df21 <- clean(degrees21, 21)
df22 <- clean(degrees22, 22)

## 2. correct major names in 2018 and 2019 data 

remove18 <- c('European Studies/Civilization', 
              'Social Sciences, General', 
              'Latin Language and Literature', 
              'Ancient/Classical Greek Language and Literature')

remove19 <- c('European Studies/Civilization', 
              'Social Sciences, General')

remove22 <- c('Social and Philosophical Foundations of Education', 
              'Ancient/Classical Greek Language and Literature')

change <- c('Film/Cinema/Video Studies', 
            'Hispanic-American, Puerto Rican, and Mexican-American/Chicano Studies', 
            'Sociology', 
            'Anthropology', 
            'Economics, General')

change2 <- c('Film/Cinema/Media Studies', 
             'Latin American Studies', 
             'Sociology, General', 
             'Anthropology, General', 
             'Econometrics and Quantitative Economics')

for(i in 1:nrow(df18)){
  for(j in 1:length(change))
    if(df18[i, 'code'] == change[j]){
      df18[i, 'code'] <- change2[j]
    }
}

for(i in 1:nrow(df19)){
  for(j in 1:length(change))
    if(df19[i, 'code'] == change[j]){
      df19[i, 'code'] <- change2[j]
    }
}

df18 <- df18[-c(which(df18$code %in% remove18)), ]
df19 <- df19[-c(which(df19$code %in% remove19)), ]
df22 <- df22[-c(which(df22$code %in% remove22)), ]

## 3. consolidate majors into groups

# 38 majors vary a lot in size so I will consolidate the following majors into groups:
# * Combine Astronomy (avg of 3 majors per year) and Physics
# * Combine Theater & Dance (avg of 3.25 majors per year) and Art
# * Create a new European Studies grouping that encompasses German (2.25), Classics (2.25), Russian (3.75), French (15.5)
# I have verified that the demographics are relatively similar within each grouping

switch_from <- c('Astronomy', 
                 'German Language and Literature', 
                 'Classics and Classical Languages, Literatures, and Linguistics, General', 
                 'Russian Language and Literature', 
                 'French Language and Literature', 
                 'Drama and Dramatics/Theatre Arts, General')

switch_to <- c('Physics, General', 
               'European Studies and Languages', 
               'European Studies and Languages', 
               'European Studies and Languages', 
               'European Studies and Languages', 
               'European Studies and Languages', 
               'Art/Art Studies, General')

regroup <- function (df){
  for(i in 1:nrow(df)){
    for(j in 1:length(switch_from)){
      if(df$code[i] == switch_from[j]){
        df$code[i] <- switch_to[j]
      }
    }
  }
  
  df <- df %>% 
    group_by(code) %>% 
    summarise(across(total:white, ~ sum(as.numeric(.x))))
  
  return(df)
}

df18 <- regroup(df18)
df19 <- regroup(df19)
df20 <- regroup(df20)
df21 <- regroup(df21)
df22 <- regroup(df22)

## 4. bind all years together
all <- rbind(df18, df19, df20, df21, df22)


## 5. calculate totals and write to csv

# total number of degrees conferred over 5 years = 2927
total_degrees_conferred <- sum(df18$total) + sum(df19$total) + sum(df20$total) + sum(df21$total) + sum(df22$total)


# calculate major representation of each group (proportion)
# 1. for each year, calculate percentage for each major
# 2. take 5-year average
p <- all %>% 
  mutate(across(2:8, ~ ifelse(.x == 'NaN', 0, .x))) %>% 
  mutate(across(3:8, ~ ifelse(.x != 0, round(((.x)/total)*100, 1), .x))) %>% 
  group_by(code) %>% 
  summarise(across(total:white, ~ round(mean(as.numeric(.x)), 2))) 

# calculate number of majors per group (count)
# 1. take 5-year average 
p2 <- all %>% 
  mutate(across(2:8, ~ ifelse(.x == 'NaN', 0, .x))) %>% 
  group_by(code) %>% 
  summarise(across(total:white, ~ round(mean(as.numeric(.x)), 2))) 

# need p2 to get average proportions for each demographic group for the entire sample
total <- sum(p2$total)
totals <- c()
for(i in 3:ncol(p2)){
  totals <- append(totals, round((sum(p2[i])/total)*100, 1))
}

# bind tables together
final <- rbind(p, c('Total', total, totals)) %>% 
  mutate(across(2:8, ~ as.numeric(.x)))

final <- final %>% 
  rename(degree = code) %>% 
  left_join(select(degree_df, c(degree, code, field)), by = 'degree')

# write to csv
write.csv(final, "data/degrees_data.csv", row.names = FALSE)



#### Network Data - Course Catalog ####

# data source: Amherst College Course Catalog: 2022-2023. 
# https://www.amherst.edu/academiclife/college-catalog/2223

# read-in data
# note: data scraped from Amherst course catalog
all <- read_csv("data/2223_courses.csv") 

# extract cross-listings 
extract_crosslistings <- function(df) {
  
  all <- df
  
  uncrosslisted <- all[which(!is.na(all$dept)&is.na(all$dept2)),]
  crosslisted2 <- all[which(!is.na(all$dept2)&is.na(all$dept3)),]
  crosslisted3 <- all[which(!is.na(all$dept3)&is.na(all$dept4)),]
  crosslisted4 <- all[which(!is.na(all$dept4)),]
  all_listings <- c(uncrosslisted, crosslisted2, crosslisted3, crosslisted4)
  
  # for courses that are cross-listed in two majors (A, B), we need (AB)
  cl2a <- crosslisted2$dept
  cl2b <- crosslisted2$dept2
  
  # for courses that are cross-listed in three majors (A, B, C), we need (AB, AC, BC)
  cl3a <- c(crosslisted3$dept, crosslisted3$dept, crosslisted3$dept2)
  cl3b <- c(crosslisted3$dept2, crosslisted3$dept3, crosslisted3$dept3) 
  
  # for courses that are cross-listed in four majors (A, B, C, D), we need (AB, AC, AD, BC, BD, CD)
  cl4a <- c(crosslisted4$dept, crosslisted4$dept, crosslisted4$dept, 
            crosslisted4$dept2, crosslisted4$dept2, crosslisted4$dept3)
  cl4b <- c(crosslisted4$dept2, crosslisted4$dept3, crosslisted4$dept4,
            crosslisted4$dept3, crosslisted4$dept4, crosslisted4$dept4)
  
  # combine all combinations
  cla <- c(cl2a, cl3a, cl4a)
  clb <- c(cl2b, cl3b, cl4b)
  
  final <- tibble(from = cla, to = clb)
  
  return(final)
  
}

edge_list <- extract_crosslistings(all)

# consolidate majors into CLAS and ASLC
edge_list <- edge_list %>% 
  mutate(across(1:2, ~ ifelse(.x == "LATI|GREE", "CLAS", .x)),
         across(1:2, ~ ifelse(.x == "ARAB|CHIN", "ASLC", .x))) %>% 
  filter(from != 'COLQ') # remove COLQ (non-major)

all_listings <- c(all$dept, all$dept2, all$dept3, all$dept4)
all <- all %>% filter(!dept %in% c('ARAB', 'GREE', 'CHIN', 'LATI', 'COLQ'))
depts <- unique(all$dept) # get list of majors

num_classes <- c() # count number of distinct courses offered by each major
for(i in 1:length(depts)){
  num_classes <- append(num_classes, sum(grepl(depts[i], all_listings), na.rm = TRUE))
}

node_list <- tibble(id = depts, num_classes = num_classes) 

write.csv(edge_list, "data/edge_list.csv", row.names = FALSE)
write.csv(node_list, "data/node_list.csv", row.names = FALSE)

