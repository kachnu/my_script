#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import cookielib
from mechanize import ParseResponse, urlopen


def captcha(image):
    file = '/tmp/captcha'
    if os.system('which tesseract > /dev/null') != 0:
        print('Need Install tesseract-ocr!')
        if os.system('sudo apt-get update && sudo apt-get install -y tesseract-ocr') != 0:
            print('I do not work BEZ tesseract-ocr!')
            sys.exit()
    os.system('tesseract {} {}'.format(image, file))
    file += '.txt'
    f = open(file)
    line = f.readline()
    print(line)
    f.close()
    os.remove(file)


response = urlopen("http://www.eoddata.com/download.aspx")
forms = ParseResponse(response, backwards_compat=False)
form = forms[0]
print (form)

