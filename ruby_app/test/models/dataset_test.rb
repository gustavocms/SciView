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
      _s = DatasetSupport::SeriesSummary.new(s.series['key'], Time.utc(1999), Time.utc(2020))
      _s.instance_variable_set(:@_summary, s)
      _s
    end
  end

  let(:starts) { [Time.new(2014, 1, 1), Time.new(2013, 12, 31)] }
  let(:stops)  { [Time.new(2014, 1, 3), Time.new(2014, 1, 2)] }

  let(:series_names){ %w[series_key series_2_key] }

  describe DatasetSupport::SeriesSummary do
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

  let(:dataset_summary) { 
    DatasetSupport::DatasetSummary.new(series_names, Time.utc(1999), Time.utc(2020)).tap do |summary|
      summary.instance_variable_set(:@starts, starts)
      summary.instance_variable_set(:@stops, stops)
    end
  }

  describe DatasetSupport::DatasetSummary do
    before { dataset_summary.instance_variable_set(:@series_summaries, meta) }

    let(:dataset) do
      Dataset.new(series_1: "series_key", series_2: "series_2_key").tap do |ds|
        ds.instance_variable_set(:@summary, dataset_summary)
      end
    end

    [
      [:count, 205824],
      [:min, -100],
      [:max, 400],
      [:keys, ['series_key', 'series_2_key']],
      [:start, Time.new(2013, 12, 31) ],
      [:stop, Time.new(2014, 1, 3) ],
      [:time_extents, [Time.new(2013, 12, 31), Time.new(2014, 1, 3)]],
      [:length_in_seconds, 3.days]
    ].each do |attr, expectation|
      specify("dataset #{attr}") { dataset_summary.public_send(attr).must_equal expectation }
    end

    describe 'rollup options' do
      let(:rollup){ -> (count){ 
        dataset.tap do |d| 
          d.instance_variable_set(:@count, count) 
        end.send(:rollup_options) }
      }
      specify("count is greater than number of datapoints") { rollup.(400000).must_equal({}) }
      specify("count is less than number of datapoints") do
        rollup.(100000).must_equal({ rollup_function: 'mean', rollup_period: 'PT2.592S' })
      end
    end
  end
end
