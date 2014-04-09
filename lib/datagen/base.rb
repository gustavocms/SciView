module DataGen
  # Base class for data generators. Contains attributes and helper functions that are used
  # by all generators.
  class Base
    attr_accessor :offset,    # Constant factor added to each data point (y-value)
                  :delay,     # Time delay factor added to each data point (x-value)
                  :tolerance, # Random factor added or subtracted from each data point
                  :pct_error  # Random error as a percent of the raw value

    def initialize(offset: 0, delay: 0, tolerance: 0, pct_error: 0)
      @offset    = offset
      @delay     = delay
      @tolerance = tolerance
      @pct_error = pct_error
    end

    def adjust_value(val)
      tolerance_range = -@tolerance..@tolerance
      percent_error = -(@pct_error * val)..(@pct_error * val)
      val +
        @offset +
        Random.rand(tolerance_range) +
        Random.rand(percent_error)
    end

    def value_at(t)
      adjust_value(raw_value_at(t - @delay))
    end

    def +(other)
      Sum.new(self, other)
    end
  end
end
