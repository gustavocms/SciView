import tempodb

__author__ = 'paulmestemaker'

from tempodb.client import Client


#
# API_KEY = 'a68ffbe8f6fe4fb3bbda2782002680f0'
# API_SECRET = '3fe37f49b1bb4ae481dec13932c9bb92'
# SERIES_KEY = 'paul-python-1'


DATABASE_ID = 'fisi'
# API_KEY = DATABASE_ID    # Currently API_KEY is the same as DATABASE_ID
API_KEY = 'a68ffbe8f6fe4fb3bbda2782002680f0'
API_SECRET = '3fe37f49b1bb4ae481dec13932c9bb92'

client = Client(DATABASE_ID, API_KEY, API_SECRET)
try:
    client.create_series('paul-python-2014-06-12')
except tempodb.response.ResponseException as e:
    print "There was an error"
    print e

response = client.get_series('paul-python-2014-06-12')
series1 = response.data
series1.name = 'foobar'
series1.tags = ['baz', 'abc']
series1.attributes = {'foo': 'bar'}
client.update_series(series1)

import datetime
import random

series = 'my-series'
data = []
date = datetime.datetime(2012, 1, 1)

#writing random data
for minute in range(1, 1441):

    dp = DataPoint.from_data(date, random.random() * 100.0)
    data.append(dp)
    date = date + datetime.timedelta(minutes=1)

client.write_data(series, data)
