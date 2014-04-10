require_relative 'base'

module DataGen
  # Returns values from a standard normal distribution curve
  class Normal < Base
    attr_accessor :value, # Value of the data at the mean (not accounting for any offset)
                  :stddev # Standard deviation of the normal distribution

    def initialize(value: 1, stddev: 1, **kwargs)
      super(kwargs)
      @value  = value.to_f
      @stddev = stddev.to_f
    end

    def raw_value_at(t)
      # We'll use the `delay` attribute as the normal mean
      exponent = - (t - @delay)**2 / (2 * @stddev**2)
      factor = @value / (@stddev * Math.sqrt(2 * Math::PI))

      factor * Math.exp(exponent)
    end
  end
end
