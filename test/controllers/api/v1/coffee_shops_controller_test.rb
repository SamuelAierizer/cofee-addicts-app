# frozen_string_literal: true

require "test_helper"

class Api::V1::CoffeeShopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @csv_url = Rails.configuration.coffee_shops_csv_url
    @csv_content = <<~CSV
      Name,X,Y
      Starbucks Seattle2,47.5869,-122.3368
      Starbucks Seattle,47.5809,-122.3165
      Starbucks SF,47.5129,-122.4210
      Peets Coffee,47.6062,-122.3321
      Blue Bottle,47.6205,-122.3493
    CSV
  end

  test "returns nearest coffee shops with valid coordinates" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_equal 3, json_response[:data].length
    assert_equal "coffee_shop", json_response[:data][0][:type]
    assert json_response[:data][0][:attributes][:name].present?
    assert json_response[:data][0][:attributes][:distance].present?
  end

  test "returns JSON:API compliant response" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :data
    json_response[:data].each do |item|
      assert_includes item.keys, :id
      assert_includes item.keys, :type
      assert_includes item.keys, :attributes
      assert_includes item[:attributes].keys, :name
      assert_includes item[:attributes].keys, :x
      assert_includes item[:attributes].keys, :y
      assert_includes item[:attributes].keys, :distance
    end
  end

  test "returns 400 when x parameter is missing" do
    get "/api/v1/coffee_shops/nearest", params: { y: -122.4 }

    assert_response :bad_request
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
    assert json_response[:errors][0][:detail].include?("x")
  end

  test "returns 400 when y parameter is missing" do
    get "/api/v1/coffee_shops/nearest", params: { x: 47.6 }

    assert_response :bad_request
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
    assert json_response[:errors][0][:detail].include?("y")
  end

  test "returns 400 when x parameter is invalid" do
    get "/api/v1/coffee_shops/nearest", params: { x: "invalid", y: -122.4 }

    assert_response :bad_request
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
  end

  test "returns 400 when y parameter is invalid" do
    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: "invalid" }

    assert_response :bad_request
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
  end

  test "returns 503 when CSV fetch fails" do
    stub_request(:get, @csv_url).to_raise(SocketError.new("Network error"))

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :service_unavailable
    json_response = JSON.parse(response.body, symbolize_names: true)

    assert_includes json_response.keys, :errors
  end

  test "shops are sorted by distance (closest first)" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    distances = json_response[:data].map { |item| item[:attributes][:distance] }
    assert_equal distances.sort, distances
  end

  test "distances are rounded to 4 decimal places" do
    stub_request(:get, @csv_url).to_return(status: 200, body: @csv_content)

    get "/api/v1/coffee_shops/nearest", params: { x: 47.6, y: -122.4 }

    assert_response :success
    json_response = JSON.parse(response.body, symbolize_names: true)

    json_response[:data].each do |item|
      distance_str = item[:attributes][:distance].to_s
      decimal_places = distance_str.split(".").last.length
      assert decimal_places <= 4
    end
  end
end
