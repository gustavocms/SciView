require 'set'

# Container object to provide InfluxDB (or other metadata-less stores) with
# tags and key-value pairs
#
class MetadataDelegate < ActiveRecord::Base

  # These have the :meta_ prefix so as not to conflict with
  # ActiveRecord's :attributes method. 
  serialize :meta_tags,       Set
  serialize :meta_attributes, Hash

end
