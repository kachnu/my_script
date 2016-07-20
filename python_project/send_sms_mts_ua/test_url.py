import urllib
import urllib2

headers = {'User-Agent' : 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)'}
values = {'Host' : 'whois.ripn.net', 'Whois' : 'test.ru'}
data = urllib.urlencode(values)
req = urllib2.Request('http://www.ripn.net:8082/nic/whois/whois.cgi', data, headers)
response = urllib2.urlopen(req)
print (response.read())