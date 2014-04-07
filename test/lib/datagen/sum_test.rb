require_relative '../../test_helper'
require 'datagen/sum'
require 'datagen/line'

describe DataGen::Sum do
  it 'is the type returned by adding data generators' do
    a = DataGen::Line.new
    b = DataGen::Line.new
    (a + b).class.must_equal DataGen::Sum
  end

  it 'generates data that is the sum of the generators used to create it' do
    a = DataGen::Line.new(offset: 3)
    b = DataGen::Line.new(offset: 5)
    sum = a + b
    3.times { sum.value_at(rand(100)).must_equal 8 }
  end

  it 'adds more generators to itself when called with :+' do
    a = DataGen::Line.new(offset: 3)
    b = DataGen::Line.new(offset: 5)
    sum = a + b
    sum += DataGen::Line.new(offset: 8)
    3.times { sum.value_at(rand(100)).must_equal 16 }
  end
end
