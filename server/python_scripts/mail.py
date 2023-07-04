import smtplib
from datetime import datetime
from configparser import ConfigParser
from smtplib import SMTPException

config = ConfigParser()
configPath = '/root/python-scripts/config/config.cfg'
config.read(configPath)

smtp_host = config.get('smtp', 'smtp_host')
smtp_port = config.get('smtp', 'smtp_port')
smtp_sender = config.get('smtp', 'smtp_sender')

def pushMail(smtp_receiver, message):
	try:
		smtpObj = smtplib.SMTP(smtp_host, smtp_port)
		smtpObj.sendmail(smtp_sender, smtp_receiver, message)
		print(str(datetime.now()) + '\tSuccessfully sent email\n')
	except SMTPException:
		print(str(datetime.now()) + '\tError: unable to send email\n')
