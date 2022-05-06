# Babišobot

### For my English speaking friends:
Twitter bot gathering and reporting news about [Andrej Babiš](https://en.wikipedia.org/wiki/Andrej_Babi%C5%A1) (Czech politician).

### For my Czech speaking friends:
<p align="center">
  <img src="Maschinenmensch.png" alt="Robot face"/>
</p>

Babišobot je robot v sítích Internetu. Je to hodný robot, nesnaží se sociálních sítí použít k tomu, aby na nich vyvolal rozkol. Používá sociální sítě (konkrétně [Twitter](https://twitter.com/babisobot)) k tomu, aby nastavil zrcadlo nám, uživatelům.

Po dobu aktivního provozu každý den ráno (v 7:45 [UTC](https://cs.wikipedia.org/wiki/Koordinovan%C3%BD_sv%C4%9Btov%C3%BD_%C4%8Das) - čili krátce před devátou ranní [CET](https://cs.wikipedia.org/wiki/St%C5%99edoevropsk%C3%BD_%C4%8Das)) olíznul Twitterové API a podal zprávu o tom, co jsme si o panu Babišovi - včera manažerovi Petrimexu, dnes premiérovi <strike>v demisi</strike> a zítřek je tajemství pro všechny - v uplynulém dni řekli.  

Babišobot je zcela organický, bez přidaného cukru či umělých barviv, a 100% open source.

- - - - -

Technicky je Babišobot napsaný v [erku](https://www.r-project.org/), pro připojení na Twitterové API využívá knihovny [`rtweet`](https://github.com/mkearney/rtweet). Běží na Amazon AWS, pravidelné spouštění má na starost cron job přes knihovnu [`cronR`](https://github.com/bnosac/cronR). O rozpadnutí tweetů na jednotlivá slova a jejich lemmatizaci se stará package [`udpipe`](https://github.com/bnosac/udpipe).

Babišobot byl v aktivním provozu od roku 2018 do května 2022; nyní je archivován. CRON job neběží a AWS stanice je vypnutá, nicméně podkladová data zůstala a v případě zájmu jsou k dispozici ke stažení jako zazipované CSV [na tomto odkazu](https://jla-unsecure.s3.eu-central-1.amazonaws.com/babisobot/babisobot_202205061233.tar.xz). Pozor, komprimovaný soubor má ~ 90MB.
