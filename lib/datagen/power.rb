require_relative 'base'

module DataGen
  # Returns values from a power-law distribution
  class Power < Base
    attr_accessor :power, # The power to raise `t` to
                  :scale  # A scaling constant applied to the power function

    def initialize(power: 2, scale: 1)
      @power = power
      @scale = scale
    end

    def raw_value_at(t)
      @scale * t**@power
    end
  end
end
