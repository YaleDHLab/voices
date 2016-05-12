#!/usr/bin/env python
# -*- coding: utf-8 -*-

# usage: python parse_tweets.py; cat good_words.txt | pbcopy # copies word array into buffer
# todo: should autoremove emoji using unicode codepoints (e.g. http://unicode.org/emoji/charts/full-emoji-list.html)

from collections import Counter
from nltk.corpus import stopwords
import codecs, glob, string

stops = stopwords.words('english')
punct = set(string.punctuation)

d = Counter()

do_not_type = 'g'
bad_words = ["shit", "fuck", "ni"+do_not_type+do_not_type+"er"]
good_words = []

for i in glob.glob("tweets/wrong_move*"):
  with codecs.open(i, "r", "utf-8") as f:
    f = f.read().split("\n")[:-1]
    for r in f:
      sr = r.split("\t")
      words = sr[1].split()
      for w in words:

        if w[0] == "@":
          print "skipping", w
          continue

        if w not in stops:
          if "http" in w:
            continue

          # remove punc
          w = ''.join(c for c in w if c not in punct)

          # remove shorts
          if len(w) > 3:

            w = w.lower().replace("\u2019s","'").replace("\u201C",'')
            d[w] += 1
     

with codecs.open("good_words.txt", "w", "utf-8") as out:
  for c, w in enumerate(d):
    if c < 1000:
      out.write(w + " ")


