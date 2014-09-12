class ReadType19SingleWithUnitTest < Minitest::TDMSTest

  def test_reads_one_single_with_unit_channel_in_one_segment
    fixture_filename("type_19_single_with_unit_one_segment")
    

    assert_equal 1, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal Tdms::DataType::SingleWithUnit::Id, segments[0].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'single_group'/'single_channel'" }
    assert_equal 5, chan.values.size

    expected = %w[-2.02 -1.01 0.00 1.01 2.02]
    assert_equal expected, chan.values.map { |float| "%0.2f" % float }
  end

  def test_reads_two_single_with_unit_channels_in_one_segment
    fixture_filename("type_19_single_with_unit_two_channels_one_segment")
    

    assert_equal 1, segments.size
    assert_equal 2, segments[0].objects.size
    assert_equal Tdms::DataType::SingleWithUnit::Id, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::SingleWithUnit::Id, segments[0].objects[1].data_type_id

    chan = channels.find {|ch| ch.path == "/'single_group'/'single_channel_a'" }
    assert_equal 5, chan.values.size
    expected = %w[-2.02 -1.01 0.00 1.01 2.02]
    assert_equal expected, chan.values.map { |float| "%0.2f" % float }

    chan = channels.find {|ch| ch.path == "/'single_group'/'single_channel_b'" }
    assert_equal 5, chan.values.size
    expected = %w[2.02 1.01 0.00 -1.01 -2.02]
    assert_equal expected, chan.values.map { |float| "%0.2f" % float }
  end

  def test_reads_one_single_with_unit_channel_across_three_segments
    fixture_filename("type_19_single_with_unit_three_segments")
    

    assert_equal 3, segments.size
    assert_equal 1, segments[0].objects.size
    assert_equal 1, segments[1].objects.size
    assert_equal 1, segments[2].objects.size
    assert_equal Tdms::DataType::SingleWithUnit::Id, segments[0].objects[0].data_type_id
    assert_equal Tdms::DataType::SingleWithUnit::Id, segments[1].objects[0].data_type_id
    assert_equal Tdms::DataType::SingleWithUnit::Id, segments[2].objects[0].data_type_id

    chan = channels.find {|ch| ch.path == "/'single_group'/'single_channel'" }
    assert_equal 15, chan.values.size
    expected = %w[-2.02 -1.01 0.00 1.01 2.02
                  -2.02 -1.01 0.00 1.01 2.02
                  -2.02 -1.01 0.00 1.01 2.02]
    assert_equal expected, chan.values.map { |float| "%0.2f" % float }
  end

end
