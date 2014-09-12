class ReadType02Int16Test < Minitest::TDMSTest

  def test_reads_one_int16_channel_in_one_segment
    fixture_filename("type_02_int16_one_segment")

    assert_equal 1, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal Tdms::DataType::Int16::ID, segments[0].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'int16_group'/'int16_channel'" }
    assert_equal 5, chan.values.size

    expected = [-32_768, -16_384, 0, 16_383, 32_767]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_two_int16_channels_in_one_segment
    fixture_filename("type_02_int16_two_channels_one_segment")

    assert_equal 1, segments.size
    assert_equal 2, segments[0].objects.size
    assert_equal Tdms::DataType::Int16::ID, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Int16::ID, segments[0].objects[1].data_type_id

    chan = channels.find {|ch| ch.path == "/'int16_group'/'int16_channel_a'" }
    assert_equal 5, chan.values.size
    expected = [-32_768, -16_384, 0, 16_383, 32_767]
    assert_equal expected, chan.values.to_a

    chan = channels.find {|ch| ch.path == "/'int16_group'/'int16_channel_b'" }
    assert_equal 5, chan.values.size
    expected = [32_767, 16_383, 0, -16_384, -32_768]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_one_int16_channel_across_three_segments
    fixture_filename("type_02_int16_three_segments")

    assert_equal 3, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal 1, segments[1].objects.size
    assert_equal 1, segments[2].objects.size
    assert_equal Tdms::DataType::Int16::ID, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Int16::ID, segments[1].objects[0].data_type_id
    assert_equal Tdms::DataType::Int16::ID, segments[2].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'int16_group'/'int16_channel'" }
    assert_equal 15, chan.values.size
    expected = [-32_768, -16_384, 0, 16_383, 32_767,
                -32_768, -16_384, 0, 16_383, 32_767,
                -32_768, -16_384, 0, 16_383, 32_767]
    assert_equal expected, chan.values.to_a
  end

end
