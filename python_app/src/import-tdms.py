__author__ = 'paulmestemaker'

from nptdms import TdmsFile
from tempodb.client import Client
from tempodb.protocol import DataPoint
from secrets import API_KEY, API_SECRET, DATABASE_ID
from datetime import datetime, timedelta
import itertools
# import os

import argparse


def convert_offset_to_iso8601(time_offset, start_time=datetime(year=2014, month=1, day=1)):
    return start_time + timedelta(hours=time_offset)


def write_channel_attributes(channel, key, client):
    """
    :type channel: TdmsObject
    :param client:
    :type client: Client
    :return:
    """

    # 409 -- series already exists
    # 404 -- series not found

    try:
        response = client.create_series(key=key, attrs={"creation_method": "python-import"})
    except Exception as e:
        # TODO: make better exception
        print "Probably already exists"
        print e.message
    finally:
        response = client.get_series(key=key)
    # except ResponseException as e:
    #     print e
    # finally:
    #     response = client.create_series(key=key)

    series = response.data
    for prop, val in channel.properties.items():
        sval = "%s" % val
        if len(sval) > 0:
            # TODO: see if it makes a difference to store in non-string format for floats/ints
            series.attributes[("%s" % prop)] = sval
        else:
            # TODO: consider attributes with no values to be tags?
            print "skipping:", prop, val
            continue

    print series.attributes
    response = client.update_series(series)

    print 'Response code:', response.status
    print 'Response body:', response.data

    return


def write_to_tempo_db(client, i, series_key, tempo_data):
    print series_key, datetime.now(), i
    resp = client.write_data(series_key, tempo_data)
    # print 'Response code:', resp.status
    if resp.status != 200:
        print 'Error reason:', resp.error

    return resp


def import_channel_to_tempodb(tdms_channel, series_key=None, chunk_size=2000):
    """
    :param tdms_channel: TDMS channel
    :param series_key: If none, it will try to use the name found in the TDMS_object
    :return:
    """
    if series_key is None:
        series_key = tdms_channel.path

    print "\n", series_key

    tc_data = tdms_channel.data
    tc_time = tdms_channel.time_track()
    wf_start_time = tdms_channel.property('wf_start_time')
    data_size = len(tc_data)
    time_size = len(tc_time)

    if data_size != time_size:
        raise "Length of channel data and time are not equal (%i != %i)" % data_size, time_size

    client = Client(DATABASE_ID, API_KEY, API_SECRET)

    write_channel_attributes(tdms_channel, series_key, client)

    tempo_data = []
    start_time = datetime.now()

    i = 0
    for item_t, item_d in itertools.izip(tc_time, tc_data):

        # TODO: see if DataPoint.from_data can be any faster ... possibly create a CSV and then import the CSV
        # TODO: determine if item_d could lose some precision by casting to float
        # TODO: use proper units (e.g. look for h for hour or s for seconds)
        tempo_data.append(DataPoint.from_data(convert_offset_to_iso8601(item_t, wf_start_time), float(item_d)))

        if i % chunk_size == 0 and i > 0:
            write_to_tempo_db(client, i, series_key, tempo_data)
            tempo_data = []
        i += 1

    if len(tempo_data) > 0:
        write_to_tempo_db(client, i, series_key, tempo_data)
        del tempo_data

    end_time = datetime.now()
    duration = end_time - start_time
    print start_time, end_time, duration
    print "Data size: %i" % data_size
    print "Points/sec: %.2f" % (data_size / duration.total_seconds())
    return


def display_properties(tdms_object, level):
    if tdms_object.properties:
        display("properties:", level)
        for prop, val in tdms_object.properties.items():
            display("%s: %s" % (prop, val), level)


def display(s, indentation_level):
    print("%s%s" % (" " * 2 * indentation_level, s))


def import_tdmsfile_to_tempodb(file_path, series_key_base=None):
    # Parse the TDMS file and get a handle to the object
    tdmsfile = TdmsFile(file_path)

    # Logging options
    show_properties = True
    show_data = False
    show_time = False
    import_data = True

    count = 0
    level = 0
    root = tdmsfile.object()
    display('/', level)
    if show_properties:
        display_properties(root, level)
    for group in tdmsfile.groups():
        level = 1
        group_obj = tdmsfile.object(group)
        display("%s" % group_obj.path, level)
        if show_properties:
            display_properties(group_obj, level)
        for channel in tdmsfile.group_channels(group):
            level = 2
            display("%s" % channel.path, level)
            if show_properties:
                level = 3
                display("data type: %s" % channel.data_type.name, level)
                display_properties(channel, level)

            if show_data:
                level = 3
                data = channel.data
                display("data: %s" % data, level)

            if show_time:
                level = 3
                time = channel.time_track()
                display("time: %s" % time, level)

            if import_data:
                level = 3
                try:
                    if series_key_base:
                        series_key = "%s-%i" % (series_key_base, count)
                        count += 1
                        # "Paul-Python-TDMS-1"
                    else:
                        # series_key_base = "%s-%s-%s" % os.path.basename(os.path.splitext(file_path))[0], group_obj.
                        series_key = channel.path

                    import_channel_to_tempodb(channel, series_key)

                except KeyError as ke:
                    display("There is no embedded time data in this channel.", level)
                    print ke
            print
        print


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Imports TDMS file into TempoDB")
    parser.add_argument("files", type=str, nargs='+', help="One or more TDMS files")
    args = parser.parse_args()

    # TODO: cycle through each file
    # TODO: validate file(s) exist
    # TODO: verify file is of the right format
    print args.files
    for file_path in args.files:
        print "importing... ", file_path
        import_tdmsfile_to_tempodb(file_path, "paul-python-20140728")