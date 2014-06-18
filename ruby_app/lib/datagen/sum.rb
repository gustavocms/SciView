require_relative 'base'

module DataGen
  # Represents the summation of multiple generators
  class Sum
    def initialize(*gens)
      @generators = gens
    end

    def value_at(t)
      @generators.map { |g| g.value_at(t) }.reduce(:+)
    end

    def +(other)
      @generators << other
      self
    end
  end
end
