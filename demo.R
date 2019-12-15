# airline data
# https://rstudio.com/resources/webinars/working-with-big-data-in-r/

library(tidyverse)

#connect to database
air <- src_postgres(
  dbname = 'xxxxxxxxxx',
  host = 'xxxxxxxxxx',
  port = 'xxxxxxxxxx',
  user = 'xxxxxxxxxx',
  password = 'xxxxxxxxxx')

#list table names
src_tbls(air)

#table reference with tbl
flights <- tbl(air, "flights")
flights
flights %>% tally()

#test
clean <- flights %>% 
  filter(!is.na(arrdelay), !is.na(depdelay)) %>% 
  filter(depdelay > 15, depdelay < 240) %>% 
  filter(year >= 2002 & year <= 2007) %>% 
  select(year, arrdelay, depdelay, distance, uniquecarrier)
show_query(clean)
clean %>% tally()