require_relative '../test_helper'

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
end

describe InfluxSupport::Summary do
  before do
    # Delete and recreate the database before every test.
    InfluxDB::Client.new.tap do |influx|
      influx.delete_database(INFLUX_DB_NAME) if influx.get_database_list.any? {|db| db["name"] == INFLUX_DB_NAME }
      influx.create_database(INFLUX_DB_NAME)
    end
  end

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
        puts "\n\n\nBEFORE:::"
        [(0...10), (3...13)].zip(%w[series_a, series_b]).each do |range, key|
          puts "#{range} #{key}"
          range.each {|ms| DatasetAdapters::InfluxAdapter.write_point(key, ms, start + (ms / 1000.0)) }
        end
      end

      let(:summary_a){ InfluxSupport::Summary.new(key: 'series_a') }
      let(:summary_b){ InfluxSupport::Summary.new(key: 'series_b') }
      let(:summary)  { InfluxSupport::Summary.new(keys: %w[series_a series_b]) }

      specify "sanity check" do
        Dataset.multiple_series(Time.utc(2013), Time.utc(2015), s0: 'series_b').to_hash.wont_be_empty
        Dataset.multiple_series(Time.utc(2013), Time.utc(2015), s0: 'series_a').to_hash.wont_be_empty
      end

      specify { summary_a.start.to_f.must_equal start.to_f         }
      specify { summary_a.stop.to_f.must_equal  start.to_f + 0.009 }
      specify { summary_b.start.to_f.must_equal start.to_f + 0.003 }
      specify { summary_b.stop.to_f.must_equal  start.to_f + 0.012 }
      specify { summary.start.to_f.must_equal   start.to_f         }
      specify { summary.stop.to_f.must_equal    start.to_f + 0.012 }
    end
  end
end
