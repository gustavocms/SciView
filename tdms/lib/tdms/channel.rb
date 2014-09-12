module Tdms

  class Channel 
    attr_accessor :file, :path, :data_type_id, :dimension, :num_values,
                  :raw_data_pos, :properties

    def name
      path.channel
    end

    def values
      @values ||= begin
        (if data_type == DataType::Utf8String
          StringChannelEnumerator
        else
          ChannelEnumerator
        end).new(self)
      end
    end

    def data_type
      @data_type ||= DataType.find_by_id(data_type_id)
    end
  end

  class ChannelEnumeratorBase
    include Enumerable
    attr_reader :channel

    def initialize(channel)
      @channel = channel
    end

    def size
      @size ||= channel.num_values
    end

    private

    def ensure_index_in_range(i)
      if (i < 0) || (i >= size)
        raise RangeError, "Channel %s has a range of 0 to %d, got invalid index: %d" %
                          [channel.path, size - 1, i]
      end
    end
  end

  class ChannelEnumerator < ChannelEnumeratorBase

    def each
      0.upto(size - 1) { |i| yield self[i] }
    end

    # TODO: reduce complexity
    def [](i)
      ensure_index_in_range(i)
      channel.file.seek channel.raw_data_pos + (i * channel.data_type::LENGTH_IN_BYTES)
      channel.data_type.read_from_stream(channel.file).value
    end
  end

  class StringChannelEnumerator < ChannelEnumeratorBase

    def initialize(channel)
      super(channel)
      @index_pos = channel.raw_data_pos
      @data_pos  = @index_pos + (4 * channel.num_values)
    end

    # TODO: reduce complexity
    def each
      data_pos = @data_pos

      0.upto(size - 1) do |i|
        index_pos = @index_pos + (4 * i)

        channel.file.seek index_pos
        next_data_pos = @data_pos + channel.file.read_u32

        length = next_data_pos - data_pos

        channel.file.seek data_pos
        yield channel.file.read(length)

        data_pos = next_data_pos
      end
    end

    # TODO: audit efficiency. 
    def [](i)
      ensure_index_in_range(i)
      inject(0) do |j, value|
        return value if j == i
        j += 1
      end
    end

  end

end
