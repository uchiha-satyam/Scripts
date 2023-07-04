import os
import json
import time
import pickle
from datetime import datetime
from elasticsearch import Elasticsearch
from configparser import ConfigParser
from webhook import pushWebhook
from mail import pushMail

config = ConfigParser()
configPath = '/root/python-scripts/config/config.cfg'
config.read(configPath)

api_id = config.get('python-api', 'api_id')
api_key = config.get('python-api', 'api_key')

client = Elasticsearch(
	'https://slazintern01.francecentral.cloudapp.azure.com:9200',
	verify_certs = False,
	api_key = (api_id, api_key),
	timeout = 30,
	max_retries = 10,
	retry_on_timeout = True
)

query = {
	'query': {
		'range': {
			'timestamp': {
				'from': 'now-5m',
				'to': 'now'
			}
		}
	}
}

database = {}
itemsArray = []

with open('files/data.raw','rb') as raw:
	try:
		database = pickle.load(raw)
		print(str(datetime.now()) + '\tDatabase collected from <- data.raw\n')
	except EOFError:
		database = {}
		print(str(datetime.now()) + '\tDatabase initialized as data.raw is empty\n')

def convertTime(timeDelta):
	sec = timeDelta.seconds
	day, remainder = divmod(sec,86400)
	hour, remainder = divmod(remainder,3600)
	min, remainder = divmod(remainder,60)

	convertedTime = '{} m'.format(min)
	if hour != 0:
		convertedTime = '{} h, '.format(hour) + convertedTime
	if day != 0:
		convertedTime = '{} d, '.format(day) + convertedTime

	return convertedTime

def sendAlert():

	if len(itemsArray) == 0:
		print(str(datetime.now()) + '\tNo Documents Found !\n')
		return

	data = {
		'type':'message',
		'attachments': [
			{
				'contentType':'application/vnd.microsoft.card.adaptive',
				'contentUrl': None,
				'content': {
					'type': 'AdaptiveCard',
					'$schema': 'http://adaptivecards.io/schemas/adaptive-card.json',
					'version': '1.4',
					'msteams': {
						'width': 'full'
					},
					'body': [
						{
							'type': 'TextBlock',
							'text': 'SYSTEM ALERTS',
							'wrap': True,
							'horizontalAlignment': 'Center',
							'size': 'ExtraLarge',
							'weight': 'Bolder',
							'color': 'Attention',
							'isSubtle': True
						}
					] + itemsArray
				}
			}
		]
	}

	pushWebhook(data)
	with open('files/data.raw','wb') as raw:
		pickle.dump(database,raw)
		print(str(datetime.now()) + '\tDatabase saved to -> data.raw\n')
	itemsArray.clear()

def beautify(doc,downTime):
	hostname = doc['_source']['alert']['id']
	tags = doc['_source']['rule']['tags']
	state = doc['_source']['alert']['state']
	value = json.loads(doc['_source']['context']['value'])['condition0']

	beautifulDoc = {
		'type': 'Container',
		'spacing': 'Small',
		'separator': True,
		'bleed': True,
		'style': 'emphasis',
		'items': [
			{
				'type': 'ColumnSet',
				'columns': [
					{
						'type': 'Column',
						'width': 'stretch',
						'items': [
							{
								'type': 'TextBlock',
								'text': hostname,
								'horizontalAlignment': 'Center',
								'size': 'Large',
								'color': 'Good',
								'weight': 'Bolder',
								'isSubtle': True,
								'wrap': True
							}
						]
					},
					{
						'type': 'Column',
						'width': 'stretch',
						'items': [
							{
								'type': 'TextBlock',
								'text': tags,
								'wrap': True,
								'horizontalAlignment': 'Center',
								'weight': 'Bolder',
								'size': 'Large'
							}
						]
					},
					{
						'type': 'Column',
						'width': 'stretch',
						'items': [
							{
								'type': 'TextBlock',
								'text': state,
								'wrap': True,
								'horizontalAlignment': 'Center',
								'color': 'Warning',
								'size': 'Large'
							}
						]
					},
					{
						'type': 'Column',
						'width': 'stretch',
						'items': [
							{
								'type': 'TextBlock',
								'text': value,
								'wrap': True,
								'horizontalAlignment': 'Center',
								'color': 'Attention',
								'size': 'Large'
							}
						]
					},
					{
						'type': 'Column',
						'width': 'stretch',
						'items': [
							{
								'type': 'TextBlock',
								'text': downTime,
								'wrap': True,
								'horizontalAlignment': 'Center',
								'color': 'Accent',
								'size': 'Large'
							}
						]
					}
				]
			}
		]
	}

	itemsArray.append(beautifulDoc)

def driver():

	response = client.search(index = 'kibana_alert', body = query)

	recent = {}

	for doc in response.body['hits']['hits']:
		key = doc['_source']['alert']['id'] + doc['_source']['rule']['id']
		timestamp = doc['_source']['timestamp']
		docTime = datetime.strptime(timestamp,'%Y-%m-%dT%H:%M:%S.%fZ')
		if key not in recent:
			recent[key] = doc
			continue
		timestamp = recent[key]['_source']['timestamp']
		recentTime = datetime.strptime(timestamp,'%Y-%m-%dT%H:%M:%S.%fZ')
		if docTime > recentTime:
			recent[key] = doc

	for key in list(database.keys()):
		if key not in recent:
			del database[key]

	for key in recent:
		timestamp = recent[key]['_source']['timestamp']
		recentTime = datetime.strptime(timestamp,'%Y-%m-%dT%H:%M:%S.%fZ')
		if key not in database:
			database[key] = recentTime
			beautify(recent[key],'Now')
			continue
		oldTime = database[key]
		downTime = convertTime(recentTime - oldTime)
		beautify(recent[key],downTime)

	sendAlert()

def main():
	while True:
		driver()
		time.sleep(60)

main()
