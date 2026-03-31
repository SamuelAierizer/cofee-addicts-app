# frozen_string_literal: true

require "test_helper"

class CoffeeShopParserTest < ActiveSupport::TestCase
  test "parses valid CSV data into CoffeeShop objects" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks Seattle,47.5809,-122.3165
      Peets Coffee,47.6062,-122.3321
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks Seattle", shops[0].name
    assert_equal 47.5809, shops[0].x
    assert_equal(-122.3165, shops[0].y)
    assert_equal "Peets Coffee", shops[1].name
  end

  test "skips header row" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 1, shops.length
    refute_equal "Name", shops[0].name
  end

  test "handles malformed rows with missing columns" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
      Invalid Row
      Peets,47.6,-122.4
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
    assert_equal "Peets", shops[1].name
  end

  test "handles rows with invalid coordinates (non-numeric)" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
      Bad Shop,invalid,also_invalid
      Peets,47.6,-122.4
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
    assert_equal "Peets", shops[1].name
  end

  test "handles rows with empty names" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
      ,47.6,-122.4
      Peets,47.7,-122.5
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
    assert_equal "Peets", shops[1].name
  end

  test "handles empty CSV" do
    csv_data = ""

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 0, shops.length
  end

  test "handles CSV with only header" do
    csv_data = "Name,X,Y"

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 0, shops.length
  end

  test "handles rows with extra whitespace" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks Seattle,  47.5809  ,  -122.3165
      Peets Coffee,47.6062  ,-122.3321
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks Seattle", shops[0].name
    assert_equal 47.5809, shops[0].x
  end

  test "returns array of CoffeeShop instances" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_instance_of Array, shops
    assert_instance_of CoffeeShop, shops[0]
  end

  test "handles rows with extra columns" do
    csv_data = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3,extra,data
      Peets,47.6,-122.4
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
  end

  test "parses headerless CSV (no Name,X,Y header row)" do
    csv_data = <<~CSV
      Starbucks Seattle,47.5809,-122.3165
      Peets Coffee,47.6062,-122.3321
      Blue Bottle,47.6205,-122.3493
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 3, shops.length
    assert_equal "Starbucks Seattle", shops[0].name
    assert_equal 47.5809, shops[0].x
    assert_equal(-122.3165, shops[0].y)
    assert_equal "Peets Coffee", shops[1].name
    assert_equal "Blue Bottle", shops[2].name
  end

  test "handles headerless CSV with malformed rows" do
    csv_data = <<~CSV
      Starbucks,47.5,-122.3
      Invalid Row
      Peets,47.6,-122.4
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
    assert_equal "Peets", shops[1].name
  end

  test "handles headerless CSV with invalid coordinates" do
    csv_data = <<~CSV
      Starbucks,47.5,-122.3
      Bad Shop,invalid,also_invalid
      Peets,47.6,-122.4
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
    assert_equal "Peets", shops[1].name
  end

  test "handles headerless CSV with empty names" do
    csv_data = <<~CSV
      Starbucks,47.5,-122.3
      ,47.6,-122.4
      Peets,47.7,-122.5
    CSV

    shops = CoffeeShopParser.call(csv_data)

    assert_equal 2, shops.length
    assert_equal "Starbucks", shops[0].name
    assert_equal "Peets", shops[1].name
  end

  test "distinguishes between CSV with headers and headerless CSV" do
    # With headers - 2 rows total (1 header + 1 data)
    csv_with_headers = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
    CSV

    # Headerless - 2 rows of data
    csv_without_headers = <<~CSV
      Starbucks,47.5,-122.3
      Peets,47.6,-122.4
    CSV

    shops_with = CoffeeShopParser.call(csv_with_headers)
    shops_without = CoffeeShopParser.call(csv_without_headers)

    # With headers: 1 data row
    assert_equal 1, shops_with.length
    assert_equal "Starbucks", shops_with[0].name

    # Without headers: 2 data rows
    assert_equal 2, shops_without.length
    assert_equal "Starbucks", shops_without[0].name
    assert_equal "Peets", shops_without[1].name
  end
end
