class AnnotationSerializer < ActiveModel::Serializer
  attributes :id, :message, :series_key, :timestamp
end
