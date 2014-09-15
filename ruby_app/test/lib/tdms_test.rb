require_relative '../test_helper'

describe 'Tdms' do
  specify { Tdms::VERSION.must_equal "0.0.4.alpha" }

  describe 'import' do
    # This is lifted from the example tdms import rake task.
    #

    filename = File.expand_path("fixtures/EXAMPLE.tdms")
    Tdms::File.parse(filename).tap do |doc|
      doc.channels.each_with_index do |channel, index|
        YAML.load(File.read("fixtures/tdms_#{Digest::SHA1.hexdigest(channel.path.to_s)}.yml")).tap do |expectation|
          specify("#{channel.path} path"){ channel.path.to_s.must_equal expectation[:path] }
          specify("#{channel.path} properties"){ channel.properties.must_equal expectation[:properties] }
          specify("#{channel.path} values"){ channel.values.to_a.must_equal expectation[:values] }
        end

        ## Generates the files
        #File.open("fixtures/tdms_#{Digest::SHA1.hexdigest(channel.path.to_s)}.yml", 'w') do |file|
          #file.write(YAML.dump(
            #{ path: channel.path.to_s, properties: channel.properties, values: channel.values.to_a }
          #))
        #end
      end
    end
  end
end
