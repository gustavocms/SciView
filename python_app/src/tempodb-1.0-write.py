__author__ = 'paulmestemaker'
import datetime
import random
from tempodb.client import Client
from tempodb.protocol import DataPoint
from secrets import API_KEY, API_SECRET, DATABASE_ID

# Modify these with your credentials found at: http://tempo-db.com/manage/
# DATABASE_ID = 'my-id'
# API_KEY = DATABASE_ID
# API_SECRET = 'my-secret'
SERIES_KEY = 'temp-1'

client = Client(DATABASE_ID, API_KEY, API_SECRET)

date = datetime.datetime(2012, 1, 1)

for day in range(1, 10):
    # print out the current day we are sending data for
    print date

    data = []
    # 1440 minutes in one day
    for min in range(1, 1441):
        data.append(DataPoint.from_data(date, random.random() * 50.0))
        date = date + datetime.timedelta(minutes=1)

    resp = client.write_data(SERIES_KEY, data)
    print 'Response code:', resp.status

    if resp.status != 200:
        print 'Error reason:', resp.error