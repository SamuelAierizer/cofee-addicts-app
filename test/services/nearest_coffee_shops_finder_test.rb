# frozen_string_literal: true

require "test_helper"

class NearestCoffeeShopsFinderTest < ActiveSupport::TestCase
  setup do
    @csv_url = "https://example.com/coffee_shops.csv"
    @csv_content = <<~CSV
      Name,X,Y
      Starbucks Seattle2,47.5869,-122.3368
      Starbucks Seattle,47.5809,-122.3165
      Starbucks SF,47.5129,-122.4210
      Peets Coffee,47.6062,-122.3321
      Blue Bottle,47.6205,-122.3493
    CSV
  end

  test "finds 3 nearest coffee shops" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    assert_equal 3, results.length
  end

  test "returns shops sorted by distance (closest first)" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    distances = results.map { |r| r[:distance] }
    assert_equal distances.sort, distances
  end

  test "each result contains coffee_shop and distance" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    results.each do |result|
      assert_instance_of Hash, result
      assert_includes result.keys, :coffee_shop
      assert_includes result.keys, :distance
      assert_instance_of CoffeeShop, result[:coffee_shop]
      assert_instance_of Float, result[:distance]
    end
  end

  test "handles fewer than 3 shops available" do
    csv_content = <<~CSV
      Name,X,Y
      Starbucks,47.5,-122.3
      Peets,47.6,-122.4
    CSV
    stub_request(:get, @csv_url).to_return(status: 200, body: csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    assert_equal 2, results.length
  end

  test "uses default CSV URL from configuration if not provided" do
    default_url = Rails.configuration.coffee_shops_csv_url
    stub_request(:get, default_url).to_return(status: 200, body: @csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4)
    results = finder.call

    assert_equal 3, results.length
  end

  test "calculates correct distances for example coordinates" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    assert_equal "Blue Bottle", results[0][:coffee_shop].name
    assert_equal "Starbucks Seattle2", results[1][:coffee_shop].name
    assert_equal "Peets Coffee", results[2][:coffee_shop].name
  end

  test "handles exact distance ties" do
    csv_content = <<~CSV
      Name,X,Y
      Shop A,47.5,122.3
      Shop B,47.5,122.3
      Shop C,47.6,-122.4
    CSV
    stub_request(:get, @csv_url).to_return(status: 200, body: csv_content)

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    assert_equal 3, results.length
  end

  test "raises error when CSV fetch fails" do
    stub_request(:get, @csv_url).to_raise(SocketError.new("Network error"))

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)

    assert_raises(CsvFetcher::FetchError) do
      finder.call
    end
  end

  test "handles empty CSV gracefully" do
    stub_request(:get, @csv_url).to_return(status: 200, body: "Name,X,Y")

    finder = NearestCoffeeShopsFinder.new(user_x: 47.6, user_y: -122.4, csv_url: @csv_url)
    results = finder.call

    assert_equal 0, results.length
  end
end
