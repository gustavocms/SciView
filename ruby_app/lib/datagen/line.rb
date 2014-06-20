require_relative 'base'

module DataGen
  # Generates a set of data points on a straight line
  class Line < Base
    attr_accessor :slope

    def initialize(slope: 0, **kwargs)
      super(kwargs)
      @slope = slope
    end

    def raw_value_at(t)
      @slope * Float(t)
    end
  end
end
