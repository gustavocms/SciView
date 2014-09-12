class ReadType01Int8Test < Minitest::TDMSTest

  def test_reads_one_int8_channel_in_one_segment
    fixture_filename("type_01_int8_one_segment")

    assert_equal 1, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal Tdms::DataType::Int8::Id, segments[0].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'int8_group'/'int8_channel'" }
    assert_equal 5, chan.values.size

    expected = [-128, -64, 0, 63, 127]
    assert_equal expected, chan.values.to_a
  end

  def test_reads_two_int8_channels_in_one_segment
    fixture_filename("type_01_int8_two_channels_one_segment")

    assert_equal 1, segments.size
    assert_equal 2, segments[0].objects.size
    assert_equal Tdms::DataType::Int8::Id, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Int8::Id, segments[0].objects[1].data_type_id

    channel("/'int8_group'/'int8_channel_a'") do |chan|
      assert_equal 5, chan.values.size
      expected = [-128, -64, 0, 63, 127]
      assert_equal expected, chan.values.to_a
    end

    channel("/'int8_group'/'int8_channel_b'") do |chan|
      assert_equal 5, chan.values.size
      expected = [127, 63, 0, -64, -128]
      assert_equal expected, chan.values.to_a
    end
  end

  def test_reads_one_int8_channel_across_three_segments
    fixture_filename("type_01_int8_three_segments")

    assert_equal 3, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal 1, segments[1].objects.size
    assert_equal 1, segments[2].objects.size
    assert_equal Tdms::DataType::Int8::Id, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::Int8::Id, segments[1].objects[0].data_type_id
    assert_equal Tdms::DataType::Int8::Id, segments[2].objects[0].data_type_id

    channel("/'int8_group'/'int8_channel'") do |chan|
      assert_equal 15, chan.values.size
      expected = [-128, -64, 0, 63, 127,
                  -128, -64, 0, 63, 127,
                  -128, -64, 0, 63, 127]
      assert_equal expected, chan.values.to_a
    end
  end
end
