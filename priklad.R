library(tidyverse)
library(DBI)
library(dbplyr)
library(RPostgreSQL)

myDb <- dbConnect(dbDriver('PostgreSQL'),
                  host     = "db.jla-data.net",
                  port     = 5432,
                  dbname   = "dbase",
                  user     = "babisobot", # user babisobot má pouze select práva...
                  password = "babisobot") # ... a proto jeho heslo může být na netu

tweet_data <- tbl(myDb, "babisobot") %>%
  collect()


dbDisconnect(myDb) # uklidit po sobě je slušnost :)