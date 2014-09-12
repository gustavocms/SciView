#require 'test/unit'
require 'minitest/autorun'
require 'forwardable'


class Minitest::TDMSTest < Minitest::Test 
  extend Forwardable

  attr_reader :filename
  def_delegators :doc, :segments, :channels

  def fixture_filename(fixture_name)
    @filename = File.dirname(__FILE__) + "/fixtures/#{fixture_name}.tdms"
  end

  def doc
    @doc ||= Tdms::File.parse(filename)
  end

  def channel(path)
    yield channels.find {|ch| ch.path == path }
  end
end
