#!/etc/usr/python3
# -*- coding: utf-8 -*-

import smtplib
from email.mime.text import MIMEText


def send_mail(smtp_server, port, me, you, theme, message):
    msg = MIMEText(message.encode('utf-8'), 'plain', 'UTF-8')
    msg['Subject'] = theme
    msg['From'] = me
    msg['To'] = you
    s = smtplib.SMTP(smtp_server, port)
    s.sendmail(me, [you], msg.as_string())
    s.quit()
    print('------------\nWas sent\nfrom {}\nto {}\nmessage:\n{}\n------------'.format(me, you, message))


def main():

    smtp_server = 'localhost'
    smtp_port = 25

    me = 'python@localhost.com.ua'

    you = ''
    while True:
        if '@' not in you:
            you = input('Enter e-mail:')
        else:
            break

    theme = 'python send mail'

    message = ''
    while True:
        if message == '':
            message = input('Message text:')
        else:
            break

    send_mail(smtp_server, smtp_port, me, you, theme, message)

if __name__ == '__main__':
    main()
