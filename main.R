library(twitteR)
library(purrr)
library(dplyr)
library(stringr)
library(tidytext)
library(wordcloud)
library(ggplot2)
library(xkcd)

# parametry
hledanyText <- "Babiš OR Babiše OR Babišovi OR Babišem" # Andrej Babiš v sedmi pádech 
dnes <- as.character(Sys.Date()) # dnešek
vcera <- as.character(Sys.Date() - 1) # včerejšek

# balast = stopwords; slovní vata nepřinášející informace
balast <- c("babiš", "babiše", "babišovi", "babišem", "andrej", "andreje", "andrejovi", "andrejem", "ten", "rt", "t.c", "http", "https", "a", "na", "že", "už", "to", "v", "se", "u", "mi", "po", "aby","když", "asi", "já", "k", "má",  "že", "je", "jsem", "jsme","o", "za", "si", "ale", "s", "z", "ale", "už", "tak", "do", "ve", "pro", "co", "t.co", "i", "od", "by", "mě", "jak", "mu", "jen", "ten", "bude")

# Připojení 
heslo <- readRDS("~/babisobot/heslo.rds")  # tajné heslo, viz. gitignore :)
setup_twitter_oauth(heslo$api_key,  
                    heslo$api_secret, 
                    heslo$access_token, 
                    heslo$access_token_secret)

# Hlas lidu...
tweets <- searchTwitter(hledanyText, # Andrej Babiš v sedmi pádech
                        n = 3200,  # tolik tweetů za den nebude, ale co kdyby...
                        lang = "cs", # šak sme česi, né?
                        since = vcera, # od včerejška...
                        until = dnes) # ...do dneška 

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
        axis.text = element_text(size = rel(2)),
        axis.text.x = element_text(angle = 90, hjust = 1),
        plot.title = element_text(size = rel(3), face = "bold", hjust = 0.5, 
                                  margin = margin(t = 10, b = 20, unit = "pt"))) +
  labs(title = "Včera se stalo...")

ggsave("ggplot.png", width = 16, height = 8, units = "in", dpi = 64) # čiliže 1024 na 512

# publikovat tweet
tweet(paste(dnes, ' - Babišobot pátrá, radí, informuje: v souvislosti s Andrejem Babišem nejčastěji zmiňujeme slovo "',freq[1,1],'"', sep = ""), mediaPath = "ggplot.png")