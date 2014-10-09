require 'tdms'

namespace :data do
  desc 'TDMS import'
  task :tdms_import do
    filename = File.expand_path("fixtures/EXAMPLE.tdms")
    tdms_dataset = Tdms::File.parse(filename)

    # doc.segments.each_with_index do |segment, index|
    #   puts segment.path
    #
    #   if segment.properties
    #     segment.properties.each do |prop|
    #       indented_display "#{prop.name}\t#{prop.value}", 1
    #     end
    #   end
    # end

    # puts
    # puts

    tdms_dataset.channels.each_with_index do |channel, index|

      indented_display channel.path, 0

      indented_display "#{channel.properties.length} properties", 1

      channel.properties.each do |name, value|
        indented_display "#{name}\t#{value}", 2
      end


      begin
        puts channel.time_track
      rescue KeyError => error
        puts "No time track"
      end

      0.upto(channel.values.size - 1) do |i|
        # indented_display "#{channel.values[i]}", 2
      end



      # channel.properties.each do |prop, value|
      #   indented_display "#{prop}: #{value}", 2
      # end
      # puts channel.path
      # if channel.path == "/'EXAMPLE'/'Time'"
      #   channel.properties.each do |prop|
      #     puts "#{prop.name}\t#{prop.value}"
      #   end
      # end
      # channel.values.each_with_index do |value, i|
      #   puts value
      # end
    end

  end
end

def indented_display(s, level)
  puts "#{" " * 2 * level}#{s}"
end
