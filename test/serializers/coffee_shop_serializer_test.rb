# frozen_string_literal: true

require "test_helper"

class CoffeeShopSerializerTest < ActiveSupport::TestCase
  test "serializes a single coffee shop with distance" do
    shop = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    distance = 0.1234

    serialized = CoffeeShopSerializer.new(shop, params: { distance: distance }).serializable_hash

    assert_equal :coffee_shop, serialized[:data][:type]
    assert_equal "Starbucks", serialized[:data][:attributes][:name]
    assert_equal 47.5, serialized[:data][:attributes][:x]
    assert_equal(-122.3, serialized[:data][:attributes][:y])
    assert_equal 0.1234, serialized[:data][:attributes][:distance]
  end

  test "serializes collection of coffee shops with distances" do
    shop1 = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    shop2 = CoffeeShop.new(name: "Peets", x: 47.6, y: -122.4)

    results = [
      { coffee_shop: shop1, distance: 0.1234 },
      { coffee_shop: shop2, distance: 0.5678 }
    ]

    serialized = CoffeeShopSerializer.serialize_collection(results)

    assert_equal 2, serialized[:data].length
    assert_equal "Starbucks", serialized[:data][0][:attributes][:name]
    assert_equal 0.1234, serialized[:data][0][:attributes][:distance]
    assert_equal "Peets", serialized[:data][1][:attributes][:name]
    assert_equal 0.5678, serialized[:data][1][:attributes][:distance]
  end

  test "includes all required attributes" do
    shop = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    serialized = CoffeeShopSerializer.new(shop, params: { distance: 0.1234 }).serializable_hash

    attributes = serialized[:data][:attributes]
    assert_includes attributes.keys, :name
    assert_includes attributes.keys, :x
    assert_includes attributes.keys, :y
    assert_includes attributes.keys, :distance
  end

  test "follows JSON:API structure" do
    shop = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    serialized = CoffeeShopSerializer.new(shop, params: { distance: 0.1234 }).serializable_hash

    assert_includes serialized.keys, :data
    assert_includes serialized[:data].keys, :id
    assert_includes serialized[:data].keys, :type
    assert_includes serialized[:data].keys, :attributes
  end

  test "generates unique IDs for each shop" do
    shop1 = CoffeeShop.new(name: "Starbucks", x: 47.5, y: -122.3)
    shop2 = CoffeeShop.new(name: "Peets", x: 47.6, y: -122.4)

    results = [
      { coffee_shop: shop1, distance: 0.1234 },
      { coffee_shop: shop2, distance: 0.5678 }
    ]

    serialized = CoffeeShopSerializer.serialize_collection(results)

    id1 = serialized[:data][0][:id]
    id2 = serialized[:data][1][:id]

    refute_nil id1
    refute_nil id2
  end
end
