module Tdms

  module DataType

    class Base
      attr_accessor :value

      def initialize(value=nil)
        @value = value
      end
    end

    class Int8 < Base
      ID = 0x01
      LENGTH_IN_BYTES = 1

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_i8)
      end
    end

    class Int16 < Base
      ID = 0x02
      LENGTH_IN_BYTES = 2

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_i16)
      end
    end

    class Int32 < Base
      ID = 0x03
      LENGTH_IN_BYTES = 4

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_i32)
      end
    end

    class Int64 < Base
      ID = 0x04
      LENGTH_IN_BYTES = 8

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_i64)
      end
    end

    class Uint8 < Base
      ID = 0x05
      LENGTH_IN_BYTES = 1

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_u8)
      end
    end

    class Uint16 < Base
      ID = 0x06
      LENGTH_IN_BYTES = 2

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_u16)
      end
    end

    class Uint32 < Base
      ID = 0x07
      LENGTH_IN_BYTES = 4

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_u32)
      end
    end

    class Uint64 < Base
      ID = 0x08
      LENGTH_IN_BYTES = 8

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_u64)
      end
    end

    class Single < Base
      ID = 0x09
      LENGTH_IN_BYTES = 4

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_single)
      end
    end

    class Double < Base
      ID = 0x0A
      LENGTH_IN_BYTES = 8

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_double)
      end
    end

    class SingleWithUnit < Base
      ID = 0x19
      LENGTH_IN_BYTES = 4

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_single)
      end
    end

    class DoubleWithUnit < Base
      ID = 0x1A
      LENGTH_IN_BYTES = 8

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_double)
      end
    end

    class Utf8String < Base
      ID = 0x20
      LENGTH_IN_BYTES = nil

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_utf8_string)
      end
    end

    class Boolean < Base
      ID = 0x21
      LENGTH_IN_BYTES = 1

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_bool)
      end
    end

    class Timestamp < Base
      ID = 0x44
      LENGTH_IN_BYTES = 16

      def self.read_from_stream(tdms_file)
        new(tdms_file.read_timestamp)
      end
    end

    DATA_TYPES_BY_ID = {
      Int8::ID           => Int8,
      Int16::ID          => Int16,
      Int32::ID          => Int32,
      Int64::ID          => Int64,
      Uint8::ID          => Uint8,
      Uint16::ID         => Uint16,
      Uint32::ID         => Uint32,
      Uint64::ID         => Uint64,
      Single::ID         => Single,
      SingleWithUnit::ID => SingleWithUnit,
      Double::ID         => Double,
      DoubleWithUnit::ID => DoubleWithUnit,
      Utf8String::ID     => Utf8String,
      Boolean::ID        => Boolean,
      Timestamp::ID      => Timestamp
    }

    def find_by_id(id_byte)
      DATA_TYPES_BY_ID[id_byte] || raise(ArgumentError, "Don't know type %d" % id_byte)
    end
    module_function :find_by_id

  end

end
