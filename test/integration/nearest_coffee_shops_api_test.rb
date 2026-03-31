# frozen_string_literal: true

require "test_helper"

class NearestCoffeeShopsApiTest < ActionDispatch::IntegrationTest
  setup do
    @csv_url = Rails.configuration.coffee_shops_csv_url
    @real_csv_content = <<~CSV
      Name,X,Y
      Starbucks Seattle2,47.5869,-122.3368
      Starbucks Seattle,47.5809,-122.3165
      Starbucks SF,47.5129,-122.4210
      Peets Coffee,47.6062,-122.3321
      Blue Bottle,47.6205,-122.3493
      Starbucks Olympia,47.0379,-122.9007
    CSV
  end

  test "full API flow returns correct nearest coffee shops for example coordinates" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @real_csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_equal 3, json_response[:data].length

    first_shop = json_response[:data][0]
    assert_equal "Blue Bottle", first_shop[:attributes][:name]
    assert_equal 47.6205, first_shop[:attributes][:x]
    assert_equal(-122.3493, first_shop[:attributes][:y])
    assert first_shop[:attributes][:distance] < 0.1

    second_shop = json_response[:data][1]
    assert_equal "Starbucks Seattle2", second_shop[:attributes][:name]

    third_shop = json_response[:data][2]
    assert_equal "Peets Coffee", third_shop[:attributes][:name]
  end

  test "handles malformed CSV data gracefully" do
    malformed_csv = <<~CSV
      Name,X,Y
      Valid Shop,47.5,-122.3
      Invalid Row Missing Columns
      Another Shop,invalid_x,47.5
      ,47.6,-122.4
      Good Shop,47.7,-122.5
    CSV
    stub_request(:get, @csv_url).to_return(status: 200, body: malformed_csv)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_equal 2, json_response[:data].length
    shop_names = json_response[:data].map { |s| s[:attributes][:name] }
    assert_includes shop_names, "Valid Shop"
    assert_includes shop_names, "Good Shop"
  end

  test "returns proper JSON:API error format for missing parameters" do
    get "/api/v1/coffee_shops/nearest", params: { x: 47.6 }

    assert_response :bad_request
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
    assert json_response[:errors].is_a?(Array)
    assert json_response[:errors][0][:detail].present?
  end

  test "returns proper JSON:API error format for service unavailable" do
    stub_request(:get, @csv_url).to_timeout

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :service_unavailable
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
    assert json_response[:errors][0][:detail].include?("Service unavailable")
  end

  test "distances are calculated correctly and rounded to 4 decimal places" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @real_csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    json_response[:data].each do |shop|
      distance = shop[:attributes][:distance]
      assert_instance_of Float, distance

      distance_str = distance.to_s
      if distance_str.include?(".")
        decimal_places = distance_str.split(".").last.length
        assert decimal_places <= 4, "Distance #{distance} has more than 4 decimal places"
      end
    end
  end

  test "returns shops in ascending order by distance" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @real_csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    distances = json_response[:data].map { |s| s[:attributes][:distance] }
    assert_equal distances, distances.sort
  end

  test "handles negative coordinates correctly" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @real_csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: -47.6, y: 122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_equal 3, json_response[:data].length
  end

  test "handles floating point coordinates with high precision" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @real_csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.123456789, y: -122.987654321 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_equal 3, json_response[:data].length
  end
end
