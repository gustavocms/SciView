require_relative 'periodic'

module DataGen
  # Generates a basic sine-wave data set
  class Sin < Periodic
    def raw_value_at(t)
      k = (2 * Math::PI) / @period
      (0.5 * @amplitude) * Math.sin(k * t)
    end
  end
end
