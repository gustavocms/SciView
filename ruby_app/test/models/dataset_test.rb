require 'test_helper'
require 'ostruct'

describe Dataset do
end

describe DatasetSummary do
  let(:meta) do
    OpenStruct.new({
      summary: { 
        'count' => 1024,
        'min'   => 0,
        'max'   => 200,
        'sum'   => 10293848
      },
      series: {
        'id'         => 'abcd',
        'key'        => 'series_key',
        'name'       => 'series_name',
        'tags'       => [],
        'attributes' => {},
      },
      start: Time.new(2014, 1, 1),
      stop: Time.new(2014, 1, 2)
    })
  end

  let(:summary) { DatasetSummary.new(meta) }

  specify { summary.count.must_equal 1024 }
  specify { summary.min.must_equal 0 }
  specify { summary.max.must_equal 200 }
  specify { summary.id.must_equal 'abcd' }
  specify { summary.key.must_equal 'series_key' }
  specify { summary.start.must_equal Time.new(2014, 1, 1) }
end
