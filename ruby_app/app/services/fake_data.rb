module FakeData
  # options are:
  # :time_interval (in seconds, int or float)
  # :start_time (Time object)
  # :count (integer)
  # :generator - expects a class that implements the API shown in the Generators
  #              module below. 
  #
  # New options can be implemented using the `default` method on Sampler.
  #
  # The FakeData::Sampler object implements implicit array conversion
  # and enumeration, so it can be dropped anywhere an array is expected.
  #
  def self.generate(options = {})
    Sampler.new(options)
  end

  module Generators
    # Creates reasonably realistic-looking trend data, with some fuzziness and spikes
    class VolatilityGenerator
      class << self
        def sample(n, volatility = 0.1)
          n.times.with_object([]) do |index, array|
            prev = array.last || rand(1000)
            change = volatility * (rand(200) - 100) / 100
            array << prev * (1 + change)
          end
        end
      end
    end

    # Completely random nonsense.
    class WhiteNoiseGenerator
      class << self
        def sample(n, *)
          n.times.map { rand 1000 }
        end
      end
    end
  end

  class Sampler
    def initialize(options = {})
      @options = options
    end

    def to_a
      sample
    end
    alias_method :to_ary, :to_a

    def to_h
      Hash[sample]
    end
    alias_method :to_hash, :to_h

    def each(&block)
      to_a.each(&block)
    end

    include Enumerable


    private

    attr_reader :options


    def self.default(name, default_value)
      define_method name do
        options.fetch(name, default_value)
      end
    end

    default :time_interval, 0.001
    default :start_time, Time.utc(2014, 1, 1)
    default :count, 1000
    default :generator, Generators::VolatilityGenerator

    def sample
      @sample ||= generator.sample(count).zip(timestamps).map(&:reverse)
    end

    def timestamps
      (0..Float::INFINITY).step(time_interval).lazy.map {|t| start_time + t }
    end
  end

end
