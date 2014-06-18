__author__ = 'paulmestemaker'
import datetime
import random
from tempodb.client import Client
from tempodb.protocol import DataPoint
from secrets import API_KEY, API_SECRET, DATABASE_ID

# Modify these with your credentials found at: http://tempo-db.com/manage/
SERIES_KEYS = ['paul-multi-1-1', 'paul-multi-1-2', 'paul-multi-1-3']

client = Client(DATABASE_ID, API_KEY, API_SECRET)

date = datetime.datetime(2012, 1, 1)

for day in range(1, 10):
    # print out the current day we are sending data for
    print date

    data = []
    # 1440 minutes in one day
    for min in range(1, 1441):
        for series in SERIES_KEYS:
            data.append(DataPoint.from_data(date, random.random() * 50.0,
                                            key=series))
            date = date + datetime.timedelta(minutes=1)

    resp = client.write_multi(data)
    print 'Response code:', resp.status

    if resp.status != 200:
        print 'Error reason:', resp.error