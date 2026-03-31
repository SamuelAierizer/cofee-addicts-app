# frozen_string_literal: true

class CoffeeShop
  attr_reader :id, :name, :x, :y

  def initialize(name:, x:, y:, id: nil)
    @id = id || object_id.to_s
    @name = name.to_s.strip
    @x = x.to_f
    @y = y.to_f
  end

  def ==(other)
    return false unless other.is_a?(CoffeeShop)

    name == other.name && x == other.x && y == other.y
  end
end
