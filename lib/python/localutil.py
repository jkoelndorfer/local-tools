#!/usr/bin/python

import email.mime.text
import configparser
import os
import smtplib

def send_email(recipients, subject, message, method=None):
    if isinstance(recipients, str):
        recipients = [recipients]
    config_path = os.path.join(os.environ['LOCAL_ETC'], 'misc', 'email.conf')
    config = configparser.ConfigParser()
    config.read(config_path)
    if method is None:
        method = config.sections()[0]
    host = config.get(method, 'host')
    username = config.get(method, 'username')
    password = config.get(method, 'password')
    email_msg = email.mime.text.MIMEText(message)
    email_msg['From'] = username
    email_msg['To'] = ', '.join(recipients)
    email_msg['Subject'] = subject
    smtp = smtplib.SMTP_SSL(host)
    smtp.login(username, password)
    smtp.sendmail(username, recipients, email_msg.as_string())
    smtp.quit()
