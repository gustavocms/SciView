require_relative '../test_helper'

describe Sampling do
  specify { Sampling.wont_be_nil }

  let(:dataset) { 1024.times.to_a }

  describe Sampling::CompleteDataset do
    specify { Sampling::CompleteDataset.sample(dataset, 500).must_equal dataset }
  end

  describe Sampling::DistributedReservoir do
    specify 'sample 900' do
      sample = Sampling::DistributedReservoir.sample(dataset, 900)
      sample.length.must_be_within_delta(900, 10)
    end
  end

end
