"""
http://tempo-db.com/api/read-series/#read-series-by-key
"""

import datetime
from tempodb import Client

# Modify these with your settings found at: http://tempo-db.com/manage/
API_KEY = 'a68ffbe8f6fe4fb3bbda2782002680f0'
API_SECRET = '3fe37f49b1bb4ae481dec13932c9bb92'
SERIES_KEY = 'paul-python-1'
SERIES_KEY = 'a.thermostat.1.temperature'

client = Client(API_KEY, API_SECRET)

start = datetime.date(2012, 1, 1)
end = start + datetime.timedelta(days=1)

data = client.read_key(SERIES_KEY, start, end)

for datapoint in data.data:
    print datapoint