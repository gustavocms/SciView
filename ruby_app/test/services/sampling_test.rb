require_relative '../test_helper'

describe Sampling do
  specify { Sampling.wont_be_nil }

  let(:dataset) { 1024.times.to_a }

  describe Sampling::CompleteDataset do
    specify { Sampling::CompleteDataset.sample(dataset, 500).must_equal dataset }
  end

  describe Sampling::RandomSample do
    specify 'sample 900' do
      sample = Sampling::RandomSample.sample(dataset, 900)
      sample.length.must_be_within_delta(900, 10)
    end
  end

  describe Sampling::LargestTriangleThreeBuckets do
    specify 'sample all' do
      Sampling::LargestTriangleThreeBuckets.sample(dataset, 1024).must_equal dataset
    end

  end

end
