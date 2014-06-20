require 'test_helper'

require 'datagen/sin'

describe DataGen::Sin do
  it 'has a default period of 1 (1 Hz)' do
    curve = DataGen::Sin.new
    3.times do
      t = rand
      curve.value_at(t).must_be_close_to curve.value_at(t + 1)
    end
  end

  it 'can be created with a different period' do
    curve = DataGen::Sin.new(period: 3)
    3.times do
      t = rand
      curve.value_at(t).must_be_close_to curve.value_at(t + 3)
    end
  end

  it 'has "amplitude" peak-to-trough height' do
    curve = DataGen::Sin.new(amplitude: 4, period: 2, delay: -0.5)
    height = curve.value_at(0) - curve.value_at(1)
    height.must_be_close_to 4
  end
end
