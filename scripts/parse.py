#!/usr/bin/env python

import sys, os, re

import nltk

from nltk.corpus import BracketParseCorpusReader


#
# XXX the NLTK software is horrid - sorry but it's true :/

#f = open('workfile', 'w+')
#for line in sys.stdin:
#  f.write(line)
#
#treebank = BracketParseCorpusReader("./", "")
#
##print treebank.tagged_words("workfile")
##print treebank.parsed_sents("workfile")[0]
#
#fdist = nltk.FreqDist(t for w,t in treebank.tagged_words("workfile"))
##fdist.B()
#fdist.plot()
#
#
#
#f.close()
#os.remove('workfile')

lval_list = []
for line in sys.stdin:
  m = re.match(r'^[0-9]+:(.*) (:?->|=) .*$', line)
  lval_list.append(m.group(1))

fdist = nltk.FreqDist(l for l in lval_list)
#fdist.B()
fdist.plot()
