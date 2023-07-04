import requests
import json
from datetime import datetime
from configparser import ConfigParser

config = ConfigParser()
configPath = '/root/python-scripts/config/config.cfg'
config.read(configPath)

webhook_url = config.get('webhook', 'webhook_url')
#data = {'title': 'Satyam Abhishek', 'summary': 'This is for testing purpose', 'text': 'Aaj mausam badhiya hai.'}
#response = requests.post(webhook_url, data = json.dumps(data), headers = {'Content-Type': 'application/json'})

def pushWebhook(data):

#	print(data)

	response = requests.post(webhook_url, data = json.dumps(data), headers = {'Content-Type': 'application/json'})
	if response.text=='1':
		print(str(datetime.now()) + '\tSuccess\n')
	else:
		print(str(datetime.now()) + '\tFailure\n')
		print(str(datetime.now()) + '\t' + response.text + '\n')
