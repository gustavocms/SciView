class ReadType05Uint8Test < Minitest::TDMSTest

  def test_reads_one_uint8_channel_in_one_segment
    fixture_filename("type_05_uint8_one_segment")
    

    assert_equal 1, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal Tdms::DataType::Uint8::ID, segments[0].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'uint8_group'/'uint8_channel'" }
    assert_equal 5, chan.values.size

    expected = [0, 1, 62, 127, 255]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_two_uint8_channels_in_one_segment
    fixture_filename("type_05_uint8_two_channels_one_segment")
    

    assert_equal 1, segments.size
    assert_equal 2, segments[0].objects.size
    assert_equal Tdms::DataType::Uint8::ID, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Uint8::ID, segments[0].objects[1].data_type_id

    chan = channels.find {|ch| ch.path == "/'uint8_group'/'uint8_channel_a'" }
    assert_equal 5, chan.values.size
    expected = [0, 1, 62, 127, 255]
    assert_equal expected, chan.values.to_a

    chan = channels.find {|ch| ch.path == "/'uint8_group'/'uint8_channel_b'" }
    assert_equal 5, chan.values.size
    expected = [255, 127, 62, 1, 0]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_one_uint8_channel_across_three_segments
    fixture_filename("type_05_uint8_three_segments")
    

    assert_equal 3, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal 1, segments[1].objects.size
    assert_equal 1, segments[2].objects.size
    assert_equal Tdms::DataType::Uint8::ID, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Uint8::ID, segments[1].objects[0].data_type_id
    assert_equal Tdms::DataType::Uint8::ID, segments[2].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'uint8_group'/'uint8_channel'" }
    assert_equal 15, chan.values.size
    expected = [0, 1, 62, 127, 255, 0, 1, 62, 127, 255, 0, 1, 62, 127, 255]
    assert_equal expected, chan.values.to_a
  end

end
