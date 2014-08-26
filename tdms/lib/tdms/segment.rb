module Tdms

  class Segment
    # Similar to a group
    attr_accessor :prev_segment, :properties, :path
    attr_reader :objects

    def initialize
      @objects = []
    end
  end

end
