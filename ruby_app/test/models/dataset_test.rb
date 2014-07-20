require 'test_helper'
require 'ostruct'
require 'rr'

describe Dataset do
  let(:meta) do
    [OpenStruct.new({
      summary: { 
        'count' => 1024,
        'min'   => -100,
        'max'   => 200,
        'sum'   => 10293848,
        'mean'  => 150
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
      summary: { 
        'count' => 204800,
        'min'   => 0,
        'max'   => 400,
        'sum'   => 10293848,
        'mean'  => 250
      },
      series: {
        'id'         => 'abcd',
        'key'        => 'series_2_key',
        'name'       => 'series_2_name',
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

  describe SeriesSummary do
    [
      [:count, 1024, 204800],
      [:mean, 150, 250],
      [:min, -100, 0],
      [:max, 200, 400],
      [:stddev, nil, nil],
      [:sum, 10293848, 10293848],
      [:id, 'abcd', 'abcd'],
      [:key, 'series_key', 'series_2_key'],
      [:name, 'series_name', 'series_2_name'],
      [:tags, [], []],
      [:attributes, {}, {}]
    ].each do |attr, *expectation|
      specify("meta #{attr.inspect}") { meta.map(&attr).must_equal expectation }
    end
  end

  describe DatasetSummary do
    let(:dataset_summary) { DatasetSummary.new(series_names, Time.utc(1999), Time.utc(2020)) }
    before { dataset_summary.instance_variable_set(:@series_summaries, meta) }

    [
      [:count, 205824],
      [:min, -100],
      [:max, 400],
      [:keys, ['series_key', 'series_2_key']],
      [:start, Time.new(2013, 12, 31) ],
      [:stop, Time.new(2014, 1, 3) ],
      [:time_extents, [Time.new(2013, 12, 31), Time.new(2014, 1, 3)]],
      # [:max_count, 204800],
      [:length_in_seconds, 3.days]
    ].each do |attr, expectation|
      specify("dataset #{attr}") { dataset_summary.public_send(attr).must_equal expectation }
    end
  end

#j  describe "dataset methods" do
#j    let(:dataset){ Dataset.new(series_1: "series_key", series_2: "series_2_key") }
#j
#j    before do
#j      # `stub` wasn't working here for some reason.
#j      dataset.instance_variable_set(:@summary, dataset_summary)
#j    end
#j
#j    specify 'summary count' do 
#j      dataset.summary.count.must_equal 205824
#j    end
#j
#j    describe 'rollup options' do
#j      let(:rollup){ -> (count){ 
#j        dataset.tap do |d| 
#j          d.instance_variable_set(:@count, count) 
#j        end.send(:rollup_options) }
#j      }
#j      specify("count is greater than number of datapoints") { rollup.(400000).must_equal({}) }
#j      specify("count is less than number of datapoints") { }
#j    end
#j  end
end

describe Iso8601Duration do

end
