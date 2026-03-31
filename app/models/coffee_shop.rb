# frozen_string_literal: true

class CoffeeShop
  attr_reader :name, :x, :y

  def initialize(name:, x:, y:)
    @name = name.to_s.strip
    @x = x.to_f
    @y = y.to_f
  end

  def ==(other)
    return false unless other.is_a?(CoffeeShop)

    name == other.name && x == other.x && y == other.y
  end
end
