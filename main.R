# ať je v logu na co koukat... :)
print(paste("Babišobot nastartován", Sys.time()))

# cesta k packagím při spuštění z příkazové řádky (i.e. cron job)
.libPaths("/usr/lib/R/site-library")

# Načtení knihoven potichu! (ať nekazí log)
library(udpipe)
library(rtweet)
library(stringr)
suppressMessages(library(tidyverse))
suppressMessages(library(xkcd))

# parametry
hledanyText <- "Babiš OR Babiše OR Babišovi OR Babišem OR Babišův OR Babišova OR Babišovo OR @AndrejBabis" 
  # Andrej Babiš v sedmi pádech a třech přídavných jménech přivlastňovacích 

dnes <- as.character(Sys.Date()) # dnešek
vcera <- as.character(Sys.Date() - 1) # včerejšek

# balast = stopwords; slovní vata nepřinášející informace
balast <- c("AndrejBabis", "Babiš", "Andrej", "ten", "rt", "t.c", "http", "https", "a", "na", "že", "už", "to", "v", "se", "u", "mi", "po", "aby", "když", "asi", "já", "k", "má",  "že", "být", "jsem", "jsme", "o", "za", "si", "ale", "s", "z", "ale", "už", "tak", "jako", "do", "ve", "pro", "co", "t.co", "i", "od", "by", "mě", "jak", "mu", "mít", "moci", "chtít", "jen", "ten", "Babis", "on", "který", "jeho", "Babišův")

# Připojení 
heslo <- readRDS("~/babisobot/heslo.rds")  # tajné heslo do databáze, viz. gitignore :)
twitter_token <- readRDS("~/babisobot/token.rds")  # tajné heslo k twitteru, dtto.
udmodel <- udpipe_load_model(file = "~/babisobot/czech-ud-2.0-170801.udpipe") # načtení modelu pro udpipe

# Hlas lidu...
tweets <- suppressWarnings( # varování o tom, že se stahlo tweetů málo není relevantní
                  search_tweets(hledanyText, # Andrej Babiš v sedmi pádech
                                n = 5000,  # tolik tweetů za den nebude, ale co kdyby...
                                lang = "cs", # šak sme česi, né?
                                since = vcera, # od včerejška...
                                until = dnes,
                                token = twitter_token)) %>% # ...do dneška 
          mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%
  filter(!(str_detect(text, "Russia") & str_detect(text, "Italy"))) # zachvatčiki, iditě domoj

# Vlastní těžení...
words <- udpipe_annotate(udmodel, x = tweets$text) %>% # UDPIPE provede svojí magii...
  as.data.frame() %>%
  filter(!upos %in% c("NUM", "PUNCT")) %>% # pryč s nevhodnými typy "slov"
  select(word = lemma) %>%
  filter(!is.na(word)) %>% # prázdná slova nechceme
  filter(!word %in% balast) # pryč s balastem nepřinášejícím informaci

  
freq <- words %>%
  count(word) %>%
  arrange(desc(n))


# uložit ggplot
plot20 <- ggplot(data = freq[1:20,], aes(x = reorder(word, -n), y = n)) +
  geom_col(fill = "darkgoldenrod2") +
  theme_xkcd() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_text(size = rel(2)),
        axis.text.x = element_text(angle = 90, hjust = 1),
        plot.title = element_text(size = rel(3), face = "bold", hjust = 0.5, 
                                  margin = margin(t = 10, b = 20, unit = "pt"))) +
  labs(title = "Vox populi tweetuje")

ggsave("~/babisobot/ggplot.png", width = 16, height = 8, units = "in", dpi = 64) # čiliže 1024 na 512

vcera <- vcera %>% # hezčí formát včerejšího dne...
  as.POSIXct() %>%
  as.character(format = "%d.%m.%Y")

autor <- tweets$screen_name[which.max(tweets$favorite_count)] # autor tweetu s největším počtem lajků
status <- tweets$status_id[which.max(tweets$favorite_count)] # status_id tweetu s největším počtem lajků
lajky <- tweets$favorite_count[which.max(tweets$favorite_count)] # nejvíce lajků ze všech

# připravit obrázek s wordcloudem
source('~/babisobot/generate-chart.R')

# publikovat tweet
obsah <- paste('Babišobot pátrá, radí, informuje: včera (', vcera, ') jsme o @AndrejBabis tweetovali ', nrow(tweets), 'x a nejčastěji zmiňovali téma "',freq[1,1],'". Autorem tweetu s ', lajky, ' lajky byl @', autor,' - https://twitter.com/i/web/status/', status , sep = "") # napřed na připravit...

post_tweet(obsah, media = "~/babisobot/wcloud.png", token = twitter_token) # ... potom vypublikovat :)

# ať je v logu na co koukat... :)
print(paste("Babišobot twitter run za", vcera, "doběhl v", Sys.time(), "GMT, tweetů bylo", nrow(tweets), "a nejčastější slovo bylo", freq[1,1])) 

# databázový běh: načíst posledních 5000 tweetů, uložit do stage vrstvy a nové IDčka překlopit do "ostré" tabulky
detach("package:udpipe", unload = T, character.only = T) # uvolnit místo..
suppressMessages(library(dbplyr))
suppressMessages(library(DBI))
suppressMessages(library(RPostgreSQL))

capture.output( {  # potichu - bez hlášek do logu
  
myDb <- dbConnect(dbDriver('PostgreSQL'),
                  host = "db.jla-data.net",
                  port = 5432,
                  user = heslo$user,
                  dbname = "dbase",
                  password = heslo$password)

tweets <- suppressWarnings(search_tweets(hledanyText, n = 5000, lang = "cs", token = twitter_token)) %>% 
  # bez ohledu na datum!
  transmute(text = text, 
            favorited = F,
            favoriteCount = favorite_count,
            replyToSN = reply_to_screen_name,
            created = created_at,
            truncated = F,
            replyToSID = reply_to_status_id,
            id = status_id,
            replyToUID = reply_to_user_id,
            statusSource = source,
            screenName = screen_name,
            retweetCount = retweet_count,
            isRetweet = is_retweet,
            longitude = NA,
            latitude = NA
            )


tweets$text <- iconv(tweets$text, "UTF-8", "UTF-8", sub = '') # pryč s non-UTF-8 znaky (nahrazuju empty stringem)

dbSendQuery(myDb, "truncate table stg_babisobot") # vyčištění stage vrstvy

db_insert_into(con = myDb, # nainsertovat nové řádky do stage vrstvy
               table = "stg_babisobot",
               values = tweets) 

dbSendQuery(myDb, "insert into babisobot select *, current_timestamp from stg_babisobot on conflict (id) do nothing") 
  # překlopit stage

dbDisconnect(myDb) # úklid

}, file = '/dev/null')

# ať je v logu na co koukat... :)
print(paste("Babišobot database run za", vcera, "doběhl v", Sys.time(), "GMT, tweetů bylo", nrow(tweets), ".")) 