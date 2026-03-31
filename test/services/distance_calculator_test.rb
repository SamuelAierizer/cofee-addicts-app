# frozen_string_literal: true

require "test_helper"

class DistanceCalculatorTest < ActiveSupport::TestCase
  test "calculates Euclidean distance between two points" do
    # Distance from (0,0) to (3,4) should be 5 (3-4-5 triangle)
    distance = DistanceCalculator.call(x1: 0, y1: 0, x2: 3, y2: 4)

    assert_equal 5.0, distance
  end

  test "returns zero for same point" do
    distance = DistanceCalculator.call(x1: 47.5, y1: -122.3, x2: 47.5, y2: -122.3)

    assert_equal 0.0, distance
  end

  test "distance is always positive" do
    distance = DistanceCalculator.call(x1: 5, y1: 5, x2: 0, y2: 0)

    assert_operator distance, :>, 0
  end

  test "rounds to 4 decimal places" do
    # sqrt(2) = 1.41421356...
    distance = DistanceCalculator.call(x1: 0, y1: 0, x2: 1, y2: 1)

    assert_equal 1.4142, distance
  end

  test "handles negative coordinates" do
    distance = DistanceCalculator.call(x1: -3, y1: -4, x2: 0, y2: 0)

    assert_equal 5.0, distance
  end

  test "handles floating point coordinates" do
    distance = DistanceCalculator.call(x1: 47.6, y1: -122.4, x2: 47.5869, y2: -122.3368)

    assert_instance_of Float, distance
    assert_equal 4, distance.to_s.split(".").last.length.clamp(1, 4)
  end

  test "is symmetric - distance A to B equals B to A" do
    distance_ab = DistanceCalculator.call(x1: 1, y1: 2, x2: 4, y2: 6)
    distance_ba = DistanceCalculator.call(x1: 4, y1: 6, x2: 1, y2: 2)

    assert_equal distance_ab, distance_ba
  end
end
