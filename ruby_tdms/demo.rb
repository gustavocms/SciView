$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'tdms'

filename = File.dirname(__FILE__) + "/test/fixtures/EXAMPLE2.tdms"
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

doc.segments.each_with_index do |segment, i|
  puts segment.path

  if segment.properties
    segment.properties.each do |prop|
      puts "#{prop.name}\t#{prop.value}"
    end
  end
end

doc.channels.each_with_index do |channel, index|
  puts channel.path
  channel.properties.each do |prop|
    puts "#{prop.name}\t#{prop.value}"
  end
  # channel.values.each_with_index do |value, i|
  #   puts value
  # end
end
