module Sampling
  class Base
    def initialize(dataset, threshold)
      @dataset   = dataset
      @threshold = threshold
    end

    # This interface ensures the complete dataset is returned
    # if the target sample is larger than the raw data size.
    def sample(&block)
      return dataset if drop <= 0
      yield dataset, length, drop, keep
    end

    attr_reader :dataset, :threshold

    def length
      @length ||= dataset.length
    end
    
    def drop
      @drop ||= length - threshold
    end

    def keep
      @keep ||= length - drop
    end
  end

  # ignores any threshold arguments; simply returns the dataset.
  class CompleteDataset 
    class << self
      def sample(dataset, *)
        dataset
      end
    end
  end

  # A non-deterministic random sample. Probabilistically close
  # to the given threshold, but not guaranteed.
  class RandomSample
    class << self
      def sample(dataset, threshold)
        sampler    = Base.new(dataset, threshold)
        drop_ratio = sampler.drop / sampler.length.to_f

        sampler.sample do |data|
          data.select {|dp| rand > drop_ratio }
        end
      end
    end
  end

  class MedianModeBucket
  end

  class MinStandardErrorBucket
  end
end
