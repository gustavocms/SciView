__author__ = 'paulmestemaker'

from nptdms import TdmsFile
import os
from datetime import datetime, timedelta



def display_properties(tdms_object, level):
    if tdms_object.properties:
        display("properties:", level)
        for prop, val in tdms_object.properties.items():
            display("%s: %s" % (prop, val), level)


def display(s, level):
    print("%s%s" % (" " * 2 * level, s))

# Determine the absolute path of the /data/ directory
data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, 'data'))

# File we want to use
# data_file = 'TR_M17_QT_42-4.tdms'
# data_file = 'TR_M17_QT_33-1.tdms'
data_file = 'EXAMPLE.tdms'

# data_file = 'Tdm_Example_File.tdm'  # This one doesn't work because it's xml and the npTDMS library doesn't support XML
# data_file = 'Tdm_Example_File.tdx'  # This one doesn't work -- not sure why

# Calculate full path for file
file_path = os.path.join(data_dir, data_file)

tdmsfile = TdmsFile(file_path)
# channel = tdmsfile.object('Group', 'Channel1')
# data = channel.data
# time = channel.time_track()

show_properties = False
show_data = False
show_time_track = False

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
        if show_time_track:
            level = 3
            try:
                time_track = channel.time_track()
                print time_track
            except KeyError:
                print "no time track"
        if show_data:
            level = 3
            data = channel.data
            print data
            # time = channel.time_track()
            # display("data: %s" % channel.data, level)


# g = 'QT_42-4_Lower'
# c = 'Temp_J'
g = 'Room temperatures'
c = 'Temperature_1'
ch = tdmsfile.object(g, c)
display_properties(ch, 3)
time_track = ch.time_track()
data = ch.data
wf_start_time = ch.properties['wf_start_time']
# print wf_start_time
# print type(wf_start_time)
# date_object = datetime.strptime('Jun 1 2005  1:33PM', '%b %d %Y %I:%M%p')
# date_object = datetime.strptime(wf_start_time, '%Y-%m-%d %H:%M:%S%p')

# print date_object
offset_units = ch.properties['wf_xunit_string']
offset_units = 'h'
for t in time_track:
    if offset_units == 'h':
        print wf_start_time + timedelta(hours=t)
    elif offset_units == 's':
        print wf_start_time + timedelta(seconds=t)




#
# print ch.properties['root_datetime']  # UTC time
# print ch.data
# print ch.time_track()
#
# print len(ch.data)
# print len(ch.time_track())
#
# print ch.properties