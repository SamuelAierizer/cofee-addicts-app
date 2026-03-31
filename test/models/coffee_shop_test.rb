# frozen_string_literal: true

require "test_helper"

class CoffeeShopTest < ActiveSupport::TestCase
  test "initializes with name, x, and y coordinates" do
    shop = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)

    assert_equal "Starbucks", shop.name
    assert_equal 47.5, shop.x
    assert_equal(-122.3, shop.y)
  end

  test "converts string coordinates to floats" do
    shop = CoffeeShop.new(name: "Coffee House", x: "47.5", y: "-122.3")

    assert_equal 47.5, shop.x
    assert_equal(-122.3, shop.y)
    assert_instance_of Float, shop.x
    assert_instance_of Float, shop.y
  end

  test "handles integer coordinates" do
    shop = CoffeeShop.new(name: "Coffee House", x: 47, y: -122)

    assert_equal 47.0, shop.x
    assert_equal(-122.0, shop.y)
  end

  test "provides read-only access to attributes" do
    shop = CoffeeShop.new(name: "Test Shop", x: 1.0, y: 2.0)

    assert_respond_to shop, :name
    assert_respond_to shop, :x
    assert_respond_to shop, :y
    refute_respond_to shop, :name=
    refute_respond_to shop, :x=
    refute_respond_to shop, :y=
  end

  test "two shops with same attributes are equal" do
    shop1 = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    shop2 = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)

    assert_equal shop1, shop2
  end

  test "two shops with different attributes are not equal" do
    shop1 = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    shop2 = CoffeeShop.new(name: "Peets", x: 47.5, y: -122.3)

    refute_equal shop1, shop2
  end

  test "handles whitespace in name" do
    shop = CoffeeShop.new(name: "  Starbucks Seattle  ", x: 47.5, y: -122.3)

    assert_equal "Starbucks Seattle", shop.name
  end
end
