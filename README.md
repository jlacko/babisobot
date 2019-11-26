# Babišobot

### For my English speaking friends:
Twitter bot gathering and reporting news about [Andrej Babiš](https://en.wikipedia.org/wiki/Andrej_Babi%C5%A1) (Czech politician).

### For my Czech speaking friends:
<p align="center">
  <img src="Maschinenmensch.png" alt="Robot face"/>
</p>

Babišobot je robot v sítích Internetu. Je to hodný robot, nesnaží se sociálních sítí použít k tomu, aby na nich vyvolal rozkol. Používá sociální sítě (konkrétně [Twitter](https://twitter.com/babisobot)) k tomu, aby nastavil zrcadlo nám, uživatelům.

Každý den ráno (v 7:45 [UTC](https://cs.wikipedia.org/wiki/Koordinovan%C3%BD_sv%C4%9Btov%C3%BD_%C4%8Das) - čili krátce před devátou ranní [CET](https://cs.wikipedia.org/wiki/St%C5%99edoevropsk%C3%BD_%C4%8Das)) olízne Twitterové API a podá zprávu o tom, co jsme si o panu Babišovi - včera manažerovi Petrimexu, dnes premiérovi <strike>v demisi</strike> a zítřek je tajemství pro všechny - v uplynulém dni řekli.  

Babišobot je zcela organický, bez přidaného cukru či umělých barviv, a 100% open source.

- - - - -

Technicky je Babišobot napsaný v [erku](https://www.r-project.org/), pro připojení na Twitterové API využívá knihovny [`rtweet`](https://github.com/mkearney/rtweet). Běží na Amazon AWS, pravidelné spouštění má na starost cron job přes knihovnu [`cronR`](https://github.com/bnosac/cronR). O rozpadnutí tweetů na jednotlivá slova a jejich lemmatizaci se stará package [`udpipe`](https://github.com/bnosac/udpipe).

Protože data jsou příliš cenná na to, aby se odreportováním zahodila, jsou všechny zpracované tweety uloženy v databázi (z technických příčin jsou tweety do půlky dubna 2018 omezeny na prvních 140 znaků - jako "starý" Twitter).

Zájemci o studium podkladových dat jsou vítáni; k přístupu použijte tento kód:

```r 
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

```