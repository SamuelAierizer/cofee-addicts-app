# frozen_string_literal: true

class DistanceCalculator
  def self.call(x1:, y1:, x2:, y2:)
    distance = Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
    distance.round(4)
  end
end
