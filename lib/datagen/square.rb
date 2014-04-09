require_relative 'periodic'

module DataGen
  # Generates a basic square-wave data set
  class Square < Periodic
    def raw_value_at(t)
      i = (t % @period) / @period
      if i < 0.5
        0.5 * @amplitude
      else
        -0.5 * @amplitude
      end
    end
  end
end
