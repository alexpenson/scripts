#!/usr/bin/env python -i
import sys
import urllib2
response = urllib2.urlopen(sys.argv[1])
page_source = response.read()

from bs4 import BeautifulSoup
soup = BeautifulSoup(page_source)
#for tr in soup.find_all('a', text="watch trailer"): print tr.get('href')


