require 'set'

# Container object to provide InfluxDB (or other metadata-less stores) with
# tags and key-value pairs
#
class MetadataDelegate < ActiveRecord::Base
  validates :key, presence: true, uniqueness: true

  # These have the :meta_ prefix so as not to conflict with
  # ActiveRecord's :attributes method. 
  serialize :meta_tags,       Set
  serialize :meta_attributes, Hash

  def tags
    meta_tags
  end

  def tags=(tags)
    self.meta_tags = Set.new(tags)
  end

  def as_json(*args)
    super(*args).tap do |hash|
      hash[:tags]       = hash.delete(:meta_tags, []).to_a
      hash[:attributes] = hash.delete(:meta_attributes, {})
    end
  end
end

