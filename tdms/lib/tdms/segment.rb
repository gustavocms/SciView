module Tdms

  class Segment
    # Similar to a group
    attr_accessor :prev_segment, :properties, :path
    attr_reader :objects

    def initialize(file = nil)
      @objects = []
      @file    = file

      # these variables need to be touched here; they rely on specific cursor positions
      @lead_in      = @file.read(0x1C)
      @metadata_pos = @file.pos
    end

    def segment
      self
    end

    def parse
      enumerate_this(raw_data_pos)
      @file.seek next_seg_pos # TODO: can we get this back into document.rb?
    end

    private

    attr_reader :lead_in, :metadata_pos

    # More details here http://www.ruby-doc.org/core-2.1.2/String.html#method-i-unpack
    # a4 = arbitrary binary string (4 bytes)
    # V = Integer | 32-bit unsigned, VAX (little-endian) byte order
    # Q = Integer | 64-bit unsigned, native endian (uint64_t)
    def unpacked
      @unpacked ||= lead_in.unpack("a4VVQQ")
    end

    def tdms_tag
      unpacked[0]
    end

    def toc_flags    
      unpacked[1]                # u32
    end

    def tdms_version 
      unpacked[2]                # u32
    end

    def next_seg_pos 
      unpacked[3] + metadata_pos # u64
    end

    def raw_data_pos 
      unpacked[4] + metadata_pos # u64
    end

    # TODO: rename this method (after figuring out what it does)
    def enumerate_this(raw_data_pos_obj)
      1.upto(@file.read_u32) do |obj_index|
        # /'Noise data' does not contain properties with Ruby library, but does with Python library
        path = Tdms::Path.new(:path => @file.read_utf8_string)
        index_block_len = @file.read_u32

        if index_block_len == 0xFFFFFFFF
          # no index block
          # Object has no data in this segment
          # Leave number_values and data_size as set previously,
          # as these may be re-used by later segments.


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
          # puts "Current position (before index block):\t#{@file.pos}"
          index_block = @file.read(index_block_len - 4)
          # puts "Current position (after index block):\t#{@file.pos}"
          # V = Integer | 32-bit unsigned, VAX (little-endian) byte order
          # Q = Integer | 64-bit unsigned, native endian (uint64_t)

          decoded = index_block.unpack("VVQ")

          chan = Tdms::Channel.new
          chan.file = @file
          chan.raw_data_pos = raw_data_pos_obj
          chan.path         = path
          chan.data_type_id = decoded[0] # first 4 bytes u32
          chan.dimension    = decoded[1] # next 4 bytes u32
          chan.num_values   = decoded[2] # next 8 bytes u64

          data_type = Tdms::DataType.find_by_id(chan.data_type_id)
          fixed_length = data_type::LENGTH_IN_BYTES

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
        # puts "#{path}: #{num_props}"
        # puts "Current position: #{@file.pos}"
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
          # NOOP
        end
        # puts "segment.properties: #{segment.properties.length}" if segment.properties
        # puts "chan.properties: #{chan.properties.length}" if chan.properties
      end
    end

  end
end
