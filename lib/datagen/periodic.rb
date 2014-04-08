require_relative 'base'

module DataGen
  # Base class for generators of periodic data.
  class Periodic < Base
    attr_accessor :period,   # Equivalent to wavelength for wave-like functions
                  :amplitude # Peak-to-trough distance for wave-like functions

    def initialize(period: 1, amplitude: 1, **kwargs)
      super(kwargs)
      @period    = period
      @amplitude = amplitude
    end
  end
end
