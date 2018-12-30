# z objektu tweets vytvoří a uloží obrázek

# Vlastní těžení...
slova <- udpipe_annotate(udmodel, x = tweets$text, doc_id = tweets$status_id) %>% # UDPIPE provede svojí magii...
  as.data.frame() %>%
  subset(upos %in% c('NOUN', 'VERB', 'PROPN', 'ADJ') & !lemma %in% balast)

freq <- slova %>%
  count(lemma) %>%
  arrange(desc(n))

library(wordcloud)
png(filename = "wcloud.png", width = 800, height = 400)
  wordcloud(freq$lemma, freq$n, max.words = 100, random.order = F, colors=rev(brewer.pal(6,"RdYlGn")))
dev.off()