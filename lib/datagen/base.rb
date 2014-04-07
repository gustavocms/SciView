module DataGen
  # Base class for data generators. Contains attributes and helper functions that are used
  # by all generators.
  class Base
    attr_accessor :offset,   # Constant factor added to each data point (y-value)
                  :delay,    # Time delay factor added to each data point (x-value)
                  :tolerance # Random factor added or subtracted from each data point

    def initialize(offset: 0, delay: 0, tolerance: 0)
      @offset    = offset
      @delay     = delay
      @tolerance = tolerance
    end

    def adjust_value(val)
      val + @offset + (@tolerance * (rand - 0.5))
    end

    def value_at(t)
      adjust_value(raw_value_at(t - @delay))
    end

    def +(other)
      Sum.new(self, other)
    end
  end
end
