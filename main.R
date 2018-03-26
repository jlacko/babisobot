# ať je v logu na co koukat... :)
print(paste("Babišobot nastartován", Sys.time()))

# cesta k packagím při spuštění z příkazové řádky (i.e. cron job)
.libPaths("/usr/lib/R/site-library")

# Načtení knihoven potichu! (ať nekazí log)
suppressMessages(library(purrr))
suppressMessages(library(dplyr))
suppressMessages(library(stringr))
suppressMessages(library(tidytext))
suppressMessages(library(ggplot2))
suppressMessages(library(xkcd))
suppressMessages(library(twitteR))

# parametry
hledanyText <- "Babiš OR Babiše OR Babišovi OR Babišem" # Andrej Babiš v sedmi pádech 
dnes <- as.character(Sys.Date()) # dnešek
vcera <- as.character(Sys.Date() - 1) # včerejšek

# balast = stopwords; slovní vata nepřinášející informace
balast <- c("babiš", "babiše", "babišovi", "babišem", "andrej", "andreje", "andrejovi", "andrejem", "ten", "rt", "t.c", "http", "https", "a", "na", "že", "už", "to", "v", "se", "u", "mi", "po", "aby","když", "asi", "já", "k", "má",  "že", "je", "jsem", "jsme","o", "za", "si", "ale", "s", "z", "ale", "už", "tak", "jako", "do", "ve", "pro", "co", "t.co", "i", "od", "by", "mě", "jak", "mu", "jen", "ten", "bude")

# Připojení 
heslo <- readRDS("~/babisobot/heslo.rds")  # tajné heslo, viz. gitignore :)
setup_twitter_oauth(heslo$api_key,  
                    heslo$api_secret, 
                    heslo$access_token, 
                    heslo$access_token_secret)

# Hlas lidu...
tweets <- suppressWarnings( # varování o tom, že se stahlo tweetů málo není relevantní
                  searchTwitter(hledanyText, # Andrej Babiš v sedmi pádech
                                n = 5000,  # tolik tweetů za den nebude, ale co kdyby...
                                lang = "cs", # šak sme česi, né?
                                since = vcera, # od včerejška...
                                until = dnes)) # ...do dneška 

# Vlastní těžení...
tweets <- tbl_df(map_df(tweets, as.data.frame))

words <- tweets %>%
  select(id, text, created) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%  # pryč s odkazy!
  unnest_tokens(word, text, token = "words") %>%  # převede do lowercase defaultně
  filter(!word %in% balast, str_detect(word, "[a-z]"))  # odstraní balast

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

ggsave("ggplot.png", width = 16, height = 8, units = "in", dpi = 64) # čiliže 1024 na 512

# publikovat tweet
tweet(paste('Babišobot pátrá, radí, informuje: včera (', vcera, ') jsme o @AndrejBabis tweetovali ', nrow(tweets), 'x a nejčastěji zmiňovali slovo"',freq[1,1],'".', sep = ""), mediaPath = "ggplot.png")

# ať je v logu na co koukat... :)
print(paste("Babišobot twitter run za", vcera, "doběhl v", Sys.time(), "GMT, tweetů bylo", nrow(tweets), "a nejčastější slovo bylo", freq[1,1])) 



# databázový běh: načíst posledních 3200 tweetů, uložit do stage vrstvy a nové IDčka překlopit do "ostré" tabulky
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

tweets <- suppressWarnings(searchTwitter(hledanyText, n = 5000, lang = "cs")) # bez ohledu na datum!
tweets <- tbl_df(map_df(tweets, as.data.frame))

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