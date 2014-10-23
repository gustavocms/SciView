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
        %{select * from "test", "test2" where time > '2013-01-01 00:00:00.000 +0000' and time < '2015-01-01 00:00:00.000 +0000'}
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
  describe :stop do
    before do
      t = start.to_f
      (0...10).each do |ms|
        DatasetAdapters::InfluxAdapter.write_point(key, ms, t + (ms / 1000.0))
      end
    end

    specify do 
      s = InfluxSupport::Summary.new(key: key).stop
      s.to_f.must_equal Time.at(start + 0.009).to_f
    end
  end
end
