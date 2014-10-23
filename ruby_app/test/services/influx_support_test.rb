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
