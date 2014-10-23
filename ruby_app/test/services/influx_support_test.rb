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
  let(:key){ 'inf_test' }
  let(:start){ Time.utc(2014) }
  describe "start and stop" do
    before do
      t = start.to_f
      (0...10).each do |ms|
        DatasetAdapters::InfluxAdapter.write_point(key, ms, t + (ms / 1000.0))
      end
    end

    let(:summary){ InfluxSupport::Summary.new(key: key) }

    specify do 
      s = summary.stop
      s.to_f.must_equal Time.at(start + 0.009).to_f
    end

    specify do
      s = summary.start
      s.to_f.must_equal Time.at(start).to_f
    end

    it "doesn't exceed the extents of the query, if given" do
      InfluxSupport::Summary.new(key: key, start: start, stop: start + 0.005).tap do |summary|
        summary.stop.must_equal(start.to_f + 0.005)
      end
    end
  end
end
