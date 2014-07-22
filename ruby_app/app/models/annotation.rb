class Annotation < ActiveRecord::Base
  def as_json(options = {})
    active_model_serializer.new(self, options).as_json
  end
end
