module Tdms

  class Document
    attr_reader :segments, :channels, :file

    def initialize(file)
      @file = file
      parse_segments
      build_aggregates
    end

    private

    def parse_segments
      @segments = []
      parse_next_segment until file.eof?
    end

    def parse_next_segment
      segments << Tdms::Segment.new(@file).tap do |segment| 
        segment.prev_segment = segments[-1]
        segment.parse
      end
    end

    def build_aggregates
      @channels = channels_by_path.map do |_, channels|
        AggregateChannel.new(channels)
      end
    end

    def channels_by_path
      segments.each_with_object({}) do |segment, _channels_by_path|
        segment.objects.select { |o| o.path.channel? }.each do |ch|
          (_channels_by_path[ch.path.to_s] ||= []) << ch
        end
      end
    end
  end

end
