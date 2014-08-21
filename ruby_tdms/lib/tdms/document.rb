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

      until file.eof?
        segment = Tdms::Segment.new
        segment.prev_segment = @segments[-1]
        @segments << segment

        lead_in = @file.read(0x1C)
        metadata_pos = @file.pos
        # More details here http://www.ruby-doc.org/core-2.1.2/String.html#method-i-unpack
        # a4 = arbitrary binary string (4 bytes)
        # V = Integer | 32-bit unsigned, VAX (little-endian) byte order
        # Q = Integer | 64-bit unsigned, native endian (uint64_t)
        unpacked = lead_in.unpack("a4VVQQ")
        tdms_tag     = unpacked[0]                # char[4]
        toc_flags    = unpacked[1]                # u32
        tdms_version = unpacked[2]                # u32
        next_seg_pos = unpacked[3] + metadata_pos # u64
        raw_data_pos = unpacked[4] + metadata_pos # u64

        new_changed_objs = @file.read_u32

        raw_data_pos_obj = raw_data_pos

        1.upto(new_changed_objs) do |obj_index|
          # /'Noise data' does not contain properties with Ruby library, but does with Python library
          path = Tdms::Path.new(:path => @file.read_utf8_string)
          index_block_len = @file.read_u32

          if index_block_len == 0xFFFFFFFF
            # no index block

          elsif index_block_len == 0x000000
            # index block is same as this channel in the last segment
            prev_chan = segment.prev_segment.objects.find {|o| o.path == path }

            chan = Tdms::Channel.new
            chan.file = @file
            chan.raw_data_pos = raw_data_pos_obj
            chan.path         = prev_chan.path
            chan.data_type_id = prev_chan.data_type_id
            chan.dimension    = prev_chan.dimension
            chan.num_values   = prev_chan.num_values

            segment.objects << chan
          else
            # XXX why does the number of properties seem to be
            # included in the raw data index block size?
            # -4 is a hack
            index_block = @file.read(index_block_len - 4)
            decoded = index_block.unpack("VVQ")

            chan = Tdms::Channel.new
            chan.file = @file
            chan.raw_data_pos = raw_data_pos_obj
            chan.path         = path
            chan.data_type_id = decoded[0] # first 4 bytes u32
            chan.dimension    = decoded[1] # next 4 bytes u32
            chan.num_values   = decoded[2] # next 8 bytes u64

            data_type = Tdms::DataType.find_by_id(chan.data_type_id)
            fixed_length = data_type::LengthInBytes

            raw_data_pos_obj += if fixed_length
              chan.num_values * fixed_length
            else
              # if the values are variable length (strings only) then
              # the index block contains 8 additional bytes at the
              # end with the total length of the raw data in u64
              index_block[-8,8].unpack("Q")[0]
            end

            segment.objects << chan
          end

          # TODO store properties
          num_props = @file.read_u32
          prop_array = []
          1.upto(num_props) do |n|
            prop = @file.read_property
            # puts "#{prop.name}\t#{prop.value}"
            prop_array << prop
          end

          if path.channel?
            chan.properties = prop_array
          elsif path.group?
            segment.properties = prop_array
          else
            # File as a whole/dataset
            # raise "This should never happen"
            puts path
          end
        end

        @file.seek next_seg_pos
      end

    end

    def build_aggregates
      @channels = []

      channels_by_path = {}
      segments.each do |segment|
        segment.objects.select { |o| o.path.channel? }.each do |ch|
          (channels_by_path[ch.path.to_s] ||= []) << ch
        end
      end

      channels_by_path.each do |path, channels|
        @channels << AggregateChannel.new(channels)
      end
    end
  end

end