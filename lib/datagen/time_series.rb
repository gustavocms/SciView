module DataGen
  # A driver for data generators that generates points between a given start and end time
  class TimeSeries
    # Only one of `frequency` or `time_points` may be specified (whichever is specified
    # last wins). Specifying both will generate a warning.
    attr_reader :frequency,  # Number of data points generated per second
                :time_points # Number of data points to be generated between start and end

    CONFLICT_MSG = <<-END.lines.map(&:lstrip).join("\n")
      Only one of `frequency` and `time_points` can be set at a time. Setting both will
      result in the second value set overriding the first.
    END
    UNSET_MSG = <<-END.lines.map(&:lstrip).join("\n")
      WARNING: Neither `frequency` nor `time_points` was set!
      Defaulting to `dt` of 1 sec.
    END

    attr_accessor :start_time, # Time-like object for the first data point
                  :end_time,   # Time-like object for the last data point

    # Gaps in the data do not affect the `frequency` specified, or will reduce the total
    # number of data points generated if `time_points` was specified
                  :gap_freq,   # The probability, for each time point, that a data point
                               # might be missing
                  :gap_size    # The average size of a gap in the data, distributed along
                               # a Poisson distribution

    include Enumerable

    def initialize(generator, start_time:, end_time:, gap_freq: 0, gap_size: 0)
      @generator = generator
      @start_time = start_time
      @end_time = end_time
      @gap_freq = gap_freq
      @gap_size = gap_size

      # Values for internal tracking
      @gap_len = 0
      @t = 0
    end

    def frequency=(new_freq)
      warn('WARNING: `time_points` was already set.\n' + CONFLICT_MSG) if @time_points
      @frequency = new_freq
      @time_points = nil
    end

    def time_points=(num_time_points)
      warn('WARNING: `frequency` was already set.\n' + CONFLICT_MSG) if @frequency
      @time_points = num_time_points
      @frequency = nil
    end

    def each
      set_dt
      while (@start_time + @t) <= @end_time
        if @gap_len > 0
          # We're currently in a gap, see if we extend it or not
          @gap_len = extend_gap ? @gap_len + 1 : 0
        else
          # Check to see if we should open a new gap
          @gap_len = 1 if rand < @gap_freq
        end

        # Don't return anything for this `@t` if we're in a gap
        yield @start_time + @t, @generator.value_at(@t) unless @gap_len > 0

        @t += @dt
      end
    end

    def set_dt
      if @frequency
        @dt = 1.0 / @frequency
      elsif @time_points
        @dt = (@end_time - @start_time).to_f / @time_points
      else
        warn(UNSET_MSG)
        @dt = 1
      end
    end

    def extend_gap
      # Simple Poisson distribution with expectation value `@gap_size`
      prob = (@gap_size**@gap_len * Math.exp(-@gap_size)) / @gap_len.downto(1).inject(:*)
      rand < prob
    end
  end
end
