require 'test_helper'
require 'ostruct'
require 'rr'

describe Dataset do
  let(:meta) do
    [OpenStruct.new({
      _summary: { 
        'count' => 1024,
        'min'   => -100,
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
      stop: Time.new(2014, 1, 3)
    }),
    OpenStruct.new({
      _summary: { 
        'count' => 204800,
        'min'   => 0,
        'max'   => 400,
        'sum'   => 10293848
      },
      series: {
        'id'         => 'abcd',
        'key'        => 'series_2_key',
        'name'       => 'series_name',
        'tags'       => [],
        'attributes' => {},
      },
      start: Time.new(2013, 12, 31),
      stop: Time.new(2014, 1, 2)
    })].map do |s|
      _s = SeriesSummary.new(s.series['key'], Time.utc(1999), Time.utc(2020))
      _s.instance_variable_set(:@_summary, s)
      _s
    end
  end

  let(:series_names){ %w[series_key series_2_key] }

  let(:dataset_summary) { DatasetSummary.new(series_names, Time.utc(1999), Time.utc(2020)) }
  before { dataset_summary.instance_variable_set(:@series_summaries, meta) }
  specify { puts dataset_summary.send(:_attr, :count).inspect }
  specify { dataset_summary.count.must_equal 205824 }
  specify { dataset_summary.min.must_equal -100 }
  specify { dataset_summary.max.must_equal 400 }
  specify { dataset_summary.keys.must_equal ['series_key', 'series_2_key'] }
  specify { dataset_summary.start.must_equal Time.new(2013, 12, 31) }
  specify { dataset_summary.stop.must_equal Time.new(2014, 1, 3) }
  specify { dataset_summary.time_extents.must_equal 3.days }
  specify { dataset_summary.max_count.must_equal 204800 }

  describe "dataset methods" do
    let(:dataset){ Dataset.new(series_1: "series_key", series_2: "series_2_key") }

    before do
      # `stub` wasn't working here for some reason.
      dataset.instance_variable_set(:@summary, dataset_summary)
    end

    specify 'summary count' do 
      dataset.summary.count.must_equal 205824
    end

    describe 'rollup options' do
      let(:rollup){ -> (count){ 
        dataset.tap do |d| 
          d.instance_variable_set(:@count, count) 
        end.send(:rollup_options) }
      }
      specify("count is greater than number of datapoints") { rollup.(400000).must_equal({}) }
      specify("count is less than number of datapoints") { }
    end
  end
end

describe Iso8601Duration do

end
