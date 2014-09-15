require_relative '../test_helper'

describe 'Tdms' do
  specify { Tdms::VERSION.must_equal "0.0.4.alpha" }

  describe 'import' do
    # This is lifted from the example tdms import rake task.
    #

    output = [].tap do |array|
      indented_display = -> (msg, level) { array << %{#{" " * 2 * level}#{msg}\n}}

      filename = File.expand_path("../python_app/data/EXAMPLE.tdms")
      Tdms::File.parse(filename).tap do |doc|
        doc.channels.each_with_index do |channel, index|
          indented_display[channel.path, 0]

          indented_display["#{channel.properties.length} properties", 1]

          channel.properties.each do |name, value|
            indented_display["#{name}\t#{value}", 2]
          end
        end
      end
    end

    output.zip(File.readlines('fixtures/tdms_output')).each_with_index do |(result, expectation), index|
      puts result.inspect
      puts expectation.inspect
      specify("index #{index}") { result.must_equal_expectation }
      break if index > 5
    end
  end
end
