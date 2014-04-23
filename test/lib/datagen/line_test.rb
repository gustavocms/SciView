require 'test_helper'
require 'datagen/line'

describe DataGen::Line do
  it 'always returns the same value by default' do
    line = DataGen::Line.new
    a = line.value_at(0)
    b = line.value_at(10)
    a.must_equal b
  end

  it 'returns the offset for any value if slope is not set' do
    line = DataGen::Line.new(offset: 5)
    3.times { line.value_at(rand(100)).must_equal 5 }
  end

  it 'returns values within tolerance of the offset' do
    line = DataGen::Line.new(offset: 5, tolerance: 2)
    3.times do
      pt = line.value_at(rand(100))
      (pt - 5).abs.must_be :<=, 2
    end
  end

  it 'plots a line with a simple slope' do
    line = DataGen::Line.new(slope: 1)
    3.times do |i|
      line.value_at(i).must_equal i
    end
  end

  it 'shifts a line on the X-axis when given a delay' do
    line = DataGen::Line.new(slope: 1)
    line.delay = 10
    3.times do |i|
      line.value_at(i + 10).must_equal i
    end
  end
end
