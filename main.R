library(twitteR)
library(purrr)
library(dplyr)
library(stringr)
library(tidytext)
library(wordcloud)
library(ggplot2)

# balast = slovní vata nepřinášející informace
balast <- data.frame(word = c("voleb", "volba",  "rt", "t.c", "http", "https", "a", "na", "že", "uŽ", "to", "v", "se","u", "mi","po", "aby","když", "asi", "já", "k", "má",  "že", "je", "jsem", "jsme","o", "za", "si", "ale", "s", "z", "ale", "už", "tak","do","ve", "pro", "už", "co", "t.co", "i", "od", "by", "mě", "jak"))

# Připojení 
heslo <- readRDS("~/babisobot/heslo.rds")  # tajné heslo, viz. gitignore :)
setup_twitter_oauth(heslo$api_key,  
                    heslo$api_secret, 
                    heslo$access_token, 
                    heslo$access_token_secret)

# Hlas lidu...
tweets <- searchTwitter("Babiš", n = 3200, lang = "cs")

# Vlastní těžení...
tweets <- tbl_df(map_df(tweets, as.data.frame))

words <- tweets %>%
  select(id, text, created) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%  # pryč s odkazy!
  unnest_tokens(word, text, token = "words") %>%  # převede do lowercase defaultně
  filter(!word %in% balast$word, str_detect(word, "[a-z]"))  # odstraní balast

freq <- words %>%
  count(word) %>%
  arrange(desc(n))


# uložit ggplot
plot20 <- ggplot(data = freq[1:20,], aes(x = reorder(word, n), y = n)) +
  geom_col(fill = "firebrick") +
  coord_flip() +
  theme_light() +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text = element_text(size = rel(1.5)),
        plot.title = element_text(size = rel(2.5), face = "bold", hjust = 0.5, 
                                  margin = margin(t = 10, b = 20, unit = "pt"))) +
  labs(title = "20 hlavních témat dneška...")

ggsave("ggplot.png", width = 8, height = 8, units = "in", dpi = 100)

# publikovat tweet
tweet("Babišobot informuje:", mediaPath = "ggplot.png")