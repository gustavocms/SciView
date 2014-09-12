class ReadType06Uint16Test < Minitest::TDMSTest

  def test_reads_one_uint16_channel_in_one_segment
    fixture_filename("type_06_uint16_one_segment")
    

    assert_equal 1, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal Tdms::DataType::Uint16::ID, segments[0].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'uint16_group'/'uint16_channel'" }
    assert_equal 5, chan.values.size

    expected = [0, 1, 16_383, 32_767, 65_535]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_two_uint16_channels_in_one_segment
    fixture_filename("type_06_uint16_two_channels_one_segment")
    

    assert_equal 1, segments.size
    assert_equal 2, segments[0].objects.size
    assert_equal Tdms::DataType::Uint16::ID, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Uint16::ID, segments[0].objects[1].data_type_id

    chan = channels.find {|ch| ch.path == "/'uint16_group'/'uint16_channel_a'" }
    assert_equal 5, chan.values.size
    expected = [0, 1, 16_383, 32_767, 65_535]
    assert_equal expected, chan.values.to_a

    chan = channels.find {|ch| ch.path == "/'uint16_group'/'uint16_channel_b'" }
    assert_equal 5, chan.values.size
    expected = [65_535, 32_767, 16_383, 1, 0]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_one_uint16_channel_across_three_segments
    fixture_filename("type_06_uint16_three_segments")
    

    assert_equal 3, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal 1, segments[1].objects.size
    assert_equal 1, segments[2].objects.size
    assert_equal Tdms::DataType::Uint16::ID, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Uint16::ID, segments[1].objects[0].data_type_id
    assert_equal Tdms::DataType::Uint16::ID, segments[2].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'uint16_group'/'uint16_channel'" }
    assert_equal 15, chan.values.size
    expected = [0, 1, 16_383, 32_767, 65_535,
                0, 1, 16_383, 32_767, 65_535,
                0, 1, 16_383, 32_767, 65_535]
    assert_equal expected, chan.values.to_a
  end

end
