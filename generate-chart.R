# z objektu tweets vytvoří a uloží obrázek

# Vlastní těžení...
slova <- udpipe_annotate(udmodel, x = tweets$text, doc_id = tweets$status_id, parallel.cores = 2) %>% # UDPIPE provede svojí magii...
  as.data.frame() %>%
  mutate(lemma = ifelse(token %in% excepto_lemmas, token, lemma)) %>% # pro tyto tokeny se nepoužije lemma, ale sám token
  subset(upos %in% c('NOUN', 'VERB', 'PROPN', 'ADJ', 'ADV') & !lemma %in% balast) # balast = stopwords definované v main.R

retweety <- tweets %>% 
  mutate(vaha = ifelse(is_retweet, 1/2, 1)) %>%  # váha retweetu je poloviční proti originálu
  select(status_id, vaha)

freq <- slova %>%
  inner_join(retweety, by = c("doc_id" = "status_id")) %>% # připojit váhy podle idčka tweetu
  group_by(lemma) %>%
  summarize(n = sum(vaha)) %>% 
  arrange(desc(n))

if (freq[1,2] > 1.5*freq[2,2]) freq[1,2] <- 1.5*freq[2,2]  # snížit prominenci prvního slova, if necessary

library(wordcloud)
png(filename = "~/babisobot/wcloud.png", width = 800, height = 800/1.91, res = 100)
  wordcloud::wordcloud(freq$lemma, freq$n, max.words = 100, scale = c(3, 0.5),
            random.order = F, colors=rev(brewer.pal(6,"RdYlGn")))
dev.off()