# ať je v logu na co koukat... :)
print(paste("Babišobot nastartován", Sys.time()))

# cesta k packagím při spuštění z příkazové řádky (i.e. cron job)
.libPaths("/usr/lib/R/site-library")

library(udpipe)
library(rtweet)
library(stringr)
suppressMessages(library(tidyverse))
suppressMessages(library(xkcd))

# udmodel <- udpipe_download_model(language = "czech")
udmodel <- udpipe_load_model(file = "czech-ud-2.0-170801.udpipe")

# parametry
hledanyText <- "Babiš OR Babiše OR Babišovi OR Babišem OR Babišův OR Babišova OR Babišovo" 
# Andrej Babiš v sedmi pádech a třech přídavných jménech přivlastňovacích 

dnes <- as.character(Sys.Date()) # dnešek
vcera <- as.character(Sys.Date() - 1) # včerejšek
twitter_token <- readRDS("~/babisobot/token.rds")  # tajné heslo k twitteru

# balast = stopwords; slovní vata nepřinášející informace
balast <- c("Babiš", "Andrej", "ten", "rt", "t.c", "http", "https", "a", "na", "že", "už", "to", "v", "se", "u", "mi", "po", "aby", "když", "asi", "já", "k", "má",  "že", "být", "jsem", "jsme", "o", "za", "si", "ale", "s", "z", "ale", "už", "tak", "jako", "do", "ve", "pro", "co", "t.co", "i", "od", "by", "mě", "jak", "mu", "jen", "ten", "Babis", "on", "který", "jeho")

tweets <- search_tweets(hledanyText, # Andrej Babiš v sedmi pádech
                n = 5000,  # tolik tweetů za den nebude, ale co kdyby...
                lang = "cs", # šak sme česi, né?
                since = vcera, # od včerejška...
                until = dnes,
                token = twitter_token) %>% # ...do dneška 
          select(id = status_id, text, created = created_at) %>%
          mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", ""))

words <- udpipe_annotate(udmodel, x = tweets$text) %>%
  as.data.frame() %>%
  filter(!upos %in% c("NUM", "PUNCT")) %>%
  select(word = lemma) %>%
  filter(!word %in% balast)


freq <- words %>%
  count(word) %>%
  arrange(desc(n))

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

plot(plot20)
