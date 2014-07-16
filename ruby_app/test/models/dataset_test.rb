require 'test_helper'

describe Dataset do
end

describe DatasetSummary do
  let(:meta) do
    { 
      'count' => 1024,
      'min'   => 0,
      'max'   => 200,
      'sum'   => 10293848
    }
  end

  let(:summary) { DatasetSummary.new(meta) }

  specify { summary.count.must_equal 1024 }
  specify { summary.min.must_equal 0 }
  specify { summary.max.must_equal 200 }
end
