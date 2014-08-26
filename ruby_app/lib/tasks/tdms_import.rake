require 'tdms'

namespace :data do
  desc 'TDMS import'
  task :tdms_import do
    # filename = File.dirname(__FILE__) + "../../../../test/fixtures/EXAMPLE2.tdms"
    filename = "/Users/paul/code/CleverPoint/sciview/python_app/data/EXAMPLE.tdms"
    doc = Tdms::File.parse(filename)

    # ch1 = doc.channels.find {|c| c.name == "StatisticsText"}
    # ch2 = doc.channels.find {|c| c.name == "Res_Noise_1"}
    #
    # last = [ch1.values.size, ch2.values.size].min - 1
    #
    # puts "#{ch1.name},#{ch2.name}"
    # 0.upto(last) do |i|
    #   puts "#{ch1.values[i]},#{ch2.values[i]}"
    # end

    doc.segments.each_with_index do |segment, index|
      puts segment.path


      if segment.properties
        segment.properties.each do |prop|
          # puts "#{prop.name}\t#{prop.value}"
          indented_display "#{prop.name}\t#{prop.value}", 1
        end
      end
    end

    puts
    puts

    doc.channels.each_with_index do |channel, index|
      indented_display channel.path, 1
      indented_display channel.properties.length, 2
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