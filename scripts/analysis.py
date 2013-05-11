#!/usr/bin/env python

import sys, re, operator

from nltk.tree import *
from nltk.draw import tree

tuple_list = []
for line in sys.stdin:
  m = re.match(r'^(.*)=\'(.*)\'$', line)
  tuple_list.append((m.group(2),m.group(1)))

tag_freq = {}
word_freq = {}
word_tag = {}

for word, tag in tuple_list:
	if not word_freq.get(word):
		word_freq[word] = 1
	else:
		word_freq[word] += 1
	if not tag_freq.get(tag):
		tag_freq[tag] = 1
	else:
		tag_freq[tag] += 1
	if not word_tag.get(word):
		word_tag[word] = {tag: 1}
	elif not word_tag.get(word).get(tag):
		word_tag[word][tag] = 1
	else:
		word_tag[word][tag] += 1

print "(#Types, #Tokens)"
print len(tag_freq), len(word_freq), "\n"

print "Most frequent tag: (tag, freq)"
print sorted(tag_freq.iteritems(), key=operator.itemgetter(1), reverse=True)[0], "\n"

word_tag_list = sorted(word_tag.iteritems(), key=operator.itemgetter(1), reverse=True)

print "Most frequent type: (word, num tags)"
print sorted(word_freq.iteritems(), key=operator.itemgetter(1), reverse=True)[0], "\n"

#print "Tagged sentences for each tag of the most tagged word: [sents]"
#tagged_sents = brown.tagged_sents(categories='news')
#tag_sents = []
#for tag,freq in word_tag_list[0][1].iteritems():
#	for sent in tagged_sents:
#		if (word_tag_list[0][0], tag) in sent:
#			tag_sents.append(sent)	
#			break
#print tag_sents, "\n"
