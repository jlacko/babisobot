# z objektu tweets vytvoří a uloží obrázek

# Vlastní těžení...
slova <- udpipe_annotate(udmodel, x = filter(tweets, !is_retweet)$text) %>% # UDPIPE provede svojí magii...
  as.data.frame() %>%
  subset(upos %in% c('NOUN', 'VERB', 'PROPN', 'ADJ', 'ADV') & !lemma %in% balast) # balast = stopwords definované v main.R

freq <- slova %>%
  count(lemma) %>%
  arrange(desc(n))

if (freq[1,2] > 1.5*freq[2,2]) freq[1,2] <- 1.5*freq[2,2]  # snížit prominenci prvního slova, if necessary

library(wordcloud)
png(filename = "~/babisobot/wcloud.png", width = 800, height = 800/1.91, res = 100)
  wordcloud(freq$lemma, freq$n, max.words = 100, scale = c(3.25, 0.5),
            random.order = F, colors=rev(brewer.pal(6,"RdYlGn")))
dev.off()