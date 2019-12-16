# airline data
# https://rstudio.com/resources/webinars/working-with-big-data-in-r/
# https://www.r-bloggers.com/create-air-travel-route-maps-in-ggplot-a-visual-travel-diary/

library(tidyverse)
library(ggmap)
library(ggrepel)

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

#which tailnum has the most flights
flights %>% group_by(tailnum) %>% count(sort = TRUE)

flights %>% filter(tailnum == 'N528') %>% group_by(year) %>% count() %>% arrange(year)

#------ map N528 flights
df <- data.frame(flights %>% filter(tailnum == 'N528'))

#look up coordinates
airports <- unique(c(df$origin, df$dest))
coords <- geocode(airports)
airports <- data.frame(airport=airports, coords)
airports <- airports %>% select(airport, lat, lon)

airports <- airports %>% mutate(lat = replace(lat, which(airport == "OAK"), 37.80440)) #clean wrong airport coords
airports <- airports %>% mutate(lon = replace(lon, which(airport == "OAK"), -122.27120))

airports <- airports %>% mutate(lat = replace(lat, which(airport == "HRL"), 26.2235)) 
airports <- airports %>% mutate(lon = replace(lon, which(airport == "HRL"), -97.6624))


#add coordinates to df
df <- merge(df, airports, by.x="origin", by.y="airport")
df <- merge(df, airports, by.x="dest", by.y="airport")

df <- df %>% rename(origin_lat = lat.x) #rename columns
df <- df %>% rename(origin_lon = lon.x)
df <- df %>% rename(dest_lat = lat.y) 
df <- df %>% rename(dest_lon = lon.y)

#sample 5% of N528 flights
df <- df %>% sample_frac(0.05, replace = TRUE)

#plot flight routes
usa_map <- borders("usa", colour="#efede1", fill="#E5D3B3") # create a layer of borders

ggplot() + usa_map + 
  geom_curve(data=df, aes(x = origin_lon, y = origin_lat, xend = dest_lon, yend = dest_lat), col = "#fdfd96", size = 0.5, curvature = .2) + 
  geom_point(data=airports, aes(x = lon, y = lat), col = "#970027", size = 3) + 
  geom_text_repel(data=airports, aes(x = lon, y = lat, label = airport), col = "black", size = 4, segment.color = NA) + 
  borders("state") +
  theme(panel.background = element_rect(fill="light blue"), 
        axis.line = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank()
  )


