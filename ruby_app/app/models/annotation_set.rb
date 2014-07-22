class AnnotationSet
  attr_reader :series_keys
  def initialize(series_keys)
    @series_keys = series_keys
  end

  def as_json
    groups
  end

  private

  def annotations
    Annotation.where(series_key: series_keys)
  end

  def groups
    Hash[annotations.group_by(&:series_key).map do |key, values|
      [key, values.map {|v| v.as_json(root: false) }]
    end]
  end
end
