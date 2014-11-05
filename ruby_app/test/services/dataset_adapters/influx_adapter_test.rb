require_relative '../../test_helper'

describe DatasetAdapters::InfluxAdapter do
  specify { INFLUX_DB_NAME.must_equal "__sciview_test" }

  before do
    # Delete and recreate the database before every test.
    InfluxDB::Client.new.tap do |influx|
      influx.delete_database(INFLUX_DB_NAME) if influx.get_database_list.any? {|db| db["name"] == INFLUX_DB_NAME }
      influx.create_database(INFLUX_DB_NAME)
    end
  end

  let(:client){ InfluxDB::Client.new(INFLUX_DB_NAME) }
  let(:adapter){ DatasetAdapters::InfluxAdapter }

  describe :all do
    specify "empty list" do
      adapter.all.tap do |result|
        result.must_be_instance_of Array
        result.must_be_empty
      end
    end

    specify "with series" do
      client.write_point('test_series', { time: Time.now.to_i, value: 100 })
      adapter.all.tap do |result|
        result.wont_be_empty
        result[0]["key"].must_equal 'test_series'
      end
    end
  end

  describe :multiple_series do
    before do
      time = Time.new(2014, 1, 1).to_i
      [[(0...10), 'series_a'], [(100...110), 'series_b']].each do |range, name|
        range.each do |value|
          client.write_point(name, { time: time + value, value: value })
        end
      end
    end

    let(:start){ Time.new(2014, 1, 1) }
    let(:stop){ Time.new(2014, 1, 2) }
    let(:names){ %w[series_a series_b] }
    # sanity check
    specify { adapter.all.map {|series| series["key"] }.must_equal names }

    let(:to_hash){ adapter.multiple_series(start, stop, { series_1: 'series_a', series_2: 'series_b' }) }
    let(:a_values){ to_hash['series_a'][:values] }
    let(:b_values){ to_hash['series_b'][:values] }

    specify "returns a hash" do
      to_hash.tap do |result|
        result.keys.must_equal names
        a_values.must_be_instance_of Array
        a_values[0].tap do |value|
          value[:ts].must_equal start
          value[:value].must_equal 0
        end

        b_values[0].tap do |value|
          value[:ts].must_equal start + 100
          value[:value].must_equal 100
        end
        
        a_values.count.must_equal 10
        b_values.count.must_equal 10

      end
    end
  end

  let(:key){ 'default_series' }
  let(:add_default_series) { -> { (1..10).each {|n| client.write_point(key, { value: n, time: (Time.new(2014, 1, 1) + n).to_i })}}} 

  describe :tagging do
    before { add_default_series.call }
    specify :add_tag do
      adapter.add_tag(key, "TEST")
      adapter.series_metadata(key)['tags'].must_include "TEST"
    end

    specify :remove_tag do
      MetadataDelegate.find_or_initialize_by(:key => key).tap do |md|
        md.tags << "TEST"
      end.save

      adapter.series_metadata(key)['tags'].must_include "TEST"
      adapter.remove_tag(key, "TEST")
      adapter.series_metadata(key)['tags'].wont_include "TEST"
    end
  end

  describe :attributes do
    before { add_default_series.call }

    specify :update_attribute do
      adapter.update_attribute(key, "test_key", "test_value")
      adapter.series_metadata(key)['attributes'].must_equal({ "test_key" => "test_value" })
      adapter.update_attribute(key, "test_key", "test_value2")
      adapter.series_metadata(key)['attributes'].must_equal({ "test_key" => "test_value2" })
    end
  end

  describe :multiple_series_metadata do
    before do
      adapter.update_attribute('series_a', 'test_key', 'test_value_a')
      adapter.update_attribute('series_b', 'test_key', 'test_value_b')
      adapter.add_tag('series_b', "TAG B")
      adapter.add_tag('series_a', "TAG A")
    end

    specify do
      adapter.multiple_series_metadata({ a: 'series_a', b: 'series_b' }).tap do |result|
        result[0]['key'].must_equal 'series_a'
        result[0]['tags'].must_include 'TAG A'
        result[0]['attributes'].must_equal({ 'test_key' => 'test_value_a' })
        result[1]['key'].must_equal 'series_b'
        result[1]['tags'].must_include 'TAG B'
        result[1]['attributes'].must_equal({ 'test_key' => 'test_value_b' })
      end
    end
  end

  describe :update_series do
    before do
      adapter.update_attribute(key, 'test_key', 'test_value_a')
      adapter.update_attribute(key, 'test_key_b', 'test_value_b')
      adapter.add_tag(key, 'TAG_A')
      adapter.add_tag(key, 'TAG_B')
    end

    let(:update_hash) {
      HashWithIndifferentAccess.new.merge({ 
        'key' => key,
        'tags' => %w[TAG_C TAG_D],
        'attributes' => { 'test_key' => 'test_value_c' }
      })
    }

    specify do
      adapter.update_series(update_hash)
      adapter.series_metadata(key).tap do |result|
        result['attributes'].must_equal({ 'test_key' => 'test_value_c' })
        result['tags'].must_equal %w[TAG_C TAG_D]
      end
    end
  end

  describe "writing" do
    before do
      t = (Time.now.to_f * 1000).to_i # milliseconds
      (1..1000).each do |n|

      end
    end
  end

  describe "aggregate & rollup functions" do
    # Adds a bunch of datapoints and returns a new series name. Options
    # are as described in services/fake_data.rb.
    let(:generate_series) do 
      -> (options = {}) {
        "__test_#{SecureRandom.hex(3)}".tap do |name|
          FakeData.generate(options).each do |ts, amp|
            DatasetAdapters::InfluxAdapter.write_point(name, amp, ts, 'ms')
          end
        end
      }
    end

    specify do
      series_name = generate_series.({ count: 10 })
      Dataset.multiple_series(nil, nil, s: series_name)[series_name][:values].count.must_equal 10
    end

    specify "when number of data points is greater than desired count" do
      series_name = generate_series.({ count: 100 })
      Dataset.multiple_series(nil, nil, { s: series_name }, 10)[series_name][:values].count.must_equal 10
    end
  end
end

describe InfluxSupport::QueryBuilder do
  let(:qb){ InfluxSupport::QueryBuilder }
  it 'requires a key or keys' do
    qb.new(:key => 'test')
    qb.new(:keys => %w[test test2])
    -> { qb.new(:no_key => 'test') }.must_raise KeyError
  end

  describe :to_s do
    [
      [{ key: 'test' },          %{select * from "test"}],
      [{ keys: %w[test test2] }, %{select * from "test", "test2"}],
      [
        { keys: %w[test test2], start: Time.utc(2013), stop: Time.utc(2015) }, 
        %{select * from "test", "test2" where time > '2013-01-01 00:00:00.000' and time < '2015-01-01 00:00:00.000'}
      ]
    ].each do |input, expectation|
      specify { qb.new(input).to_s.must_equal expectation }
    end
  end

  describe :target_counts do
  end

  describe InfluxSupport::Summary do
    let(:key){ 'inf_test' }
    let(:start){ Time.utc(2014) }
    let(:tolerance){ 0.0001 }
    describe "start and stop" do
      describe "single series" do
        before do
          (0...10).each { |ms| DatasetAdapters::InfluxAdapter.write_point(key, ms, start + (ms / 1000.0)) }
        end

        let(:summary){ InfluxSupport::Summary.new(key: key) }

        specify do 
          s = summary.stop
          s.to_f.must_be_within_delta(InfluxSupport::UTC.at(start + 0.009).to_f, tolerance)
        end

        specify do
          s = summary.start
          s.to_f.must_equal InfluxSupport::UTC.at(start).to_f
        end

        it "doesn't exceed the extents of the query, if given" do
          InfluxSupport::Summary.new(key: key, start: start, stop: start + 0.005).tap do |summary|
            summary.stop.to_f.must_be_within_delta(start.to_f + 0.005, tolerance)
          end
        end
      end

      describe "multiple series" do
        # series a |--------------------------|
        #         series b |-----------------------------|
        before do
          [(3...13), (0...10)].zip(%w[series_b series_a]).each do |range, key|
            range.each {|ms| DatasetAdapters::InfluxAdapter.write_point(key, ms, start + (ms / 1000.0)) }
          end
        end

        let(:summary_a){ InfluxSupport::Summary.new(key: 'series_a') }
        let(:summary_b){ InfluxSupport::Summary.new(key: 'series_b') }
        let(:summary)  { InfluxSupport::Summary.new(keys: %w[series_a series_b]) }
        let(:t_offset){ -> (n, t = start) { (t.to_f + n).round(3) }}

        specify "sanity check b" do
          Dataset.multiple_series(Time.utc(2013), Time.utc(2015), s0: 'series_b').to_hash.wont_be_empty
        end

        specify "sanity check a" do
          Dataset.multiple_series(Time.utc(2013), Time.utc(2015), s0: 'series_a').to_hash.wont_be_empty
        end

        specify("start a")    { t_offset[0,summary_a.start].must_equal t_offset[0]     }
        specify("start b")    { t_offset[0,summary_b.start].must_equal t_offset[0.003] }
        specify("start both") { t_offset[0,summary.start  ].must_equal t_offset[0]     }

        specify("stop a")    { t_offset[0, summary_a.stop].must_equal  t_offset[0.009] }
        specify("stop b")    { t_offset[0, summary_b.stop].must_equal  t_offset[0.012] }
        specify("stop both") { t_offset[0, summary.stop  ].must_equal  t_offset[0.012] }

        specify("time_extents") do
          extents = summary.time_extents
          t_offset[0, extents[0]].must_equal t_offset[0]
          t_offset[0, extents[1]].must_equal t_offset[0.012]
        end
      end

      describe :count do
      end

      describe :max_count do
      end

      describe :max do
      end

      describe :min do
      end
    end
  end
end
