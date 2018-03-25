# Babišobot

<p align="center">
  <img src="mugshot.png" alt="Maschinenmensch"/>
</p>

### For my English speaking friends:
Twitter bot gathering and reporting news about [Andrej Babiš](https://en.wikipedia.org/wiki/Andrej_Babi%C5%A1) (Czech politician).

### For my Czech speaking friends:
Babišobot je robot v sítích Internetu. Je to hodný robot, nesnaží se sociálních sítí použít k tomu, aby na nich vyvolal rozkol - ať už ze zlého úmyslu, či za cizí peníze. Používá sociální sítě (konkrétně [Twitter](https://twitter.com/babisobot)) k tomu, aby nastavil zrcadlo nám, jejich uživatelům.

Každý den ráno (v 5:50 [UTC](https://cs.wikipedia.org/wiki/Koordinovan%C3%BD_sv%C4%9Btov%C3%BD_%C4%8Das) - čili krátce před osmou ranní [SELČ](https://cs.wikipedia.org/wiki/St%C5%99edoevropsk%C3%BD_letn%C3%AD_%C4%8Das)) olízne Twitterové API a podá zprávu o tom, co jsme si o panu Babišovi (včera manažerovi Petrimexu, dnes premiérovi v demisi a zítřek je tajemství pro nás všechny...) v uplynulém dni řekli.  

Nepřemýšlí přitom, jestli jsme si povídali hezké či ošklivé věci, podává pouze svědectví o tom jaké názory zazněly. Jako robot umí zpracovat pouze jedničky a nuly, neví co to jsou brýle - ani růžové, ani černé.

Babišobot je zcela organický, bez přidaného cukru či umělých barviv, a 100% open source.
<hr>
Technicky je napsaný v erku, pro připojení na Twitterové API využívá knihovny `twitteR`. Běží na Amazon AWS, spouštění má na starost cron přes knihovnu `cronR`.  

Protože data jsou příliš cenná na to, aby se odreportováním zahodila, jsou všechny zpracované tweety uloženy v PostgreSQL databázi.
