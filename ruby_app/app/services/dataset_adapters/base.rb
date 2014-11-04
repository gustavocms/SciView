module DatasetAdapters
  class Base

    class << self

      private

      def fix_times(*times)
        times.map(&method(:fix_time))
      end

      def fix_time(time)
        return if time.blank?
        if time !~ /\d{4,}\-/ 
          Time.at(time.to_f)
        else
          Time.parse(time)
        end
      end
    end
  end
end
