require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

describe AnnotationSet do
  let(:text){ -> (n, m) { "Message #{m} for series #{n}" }}
  let(:annotations) do
    (1..5).map do |m|
      5.times.map do |n|
        Annotation.create(series_key: "series_#{n}", message: text[n, m], timestamp: Time.now)
      end
    end.flatten
  end

  let(:annotation_set){ AnnotationSet.new(annotations.map(&:series_key)) }
  before { annotations }

  specify { Annotation.count.must_equal 25 }
  specify "to hash" do
    annotation_set.as_json.tap do |json|
      json["series_0"].must_be_instance_of Array
      json["series_0"].count.must_equal 5
    end
  end
end
