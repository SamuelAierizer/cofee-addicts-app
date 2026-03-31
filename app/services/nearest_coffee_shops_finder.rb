# frozen_string_literal: true

class NearestCoffeeShopsFinder
  def initialize(user_x:, user_y:, csv_url: nil)
    @user_x = user_x.to_f
    @user_y = user_y.to_f
    @csv_url = csv_url || Rails.configuration.coffee_shops_csv_url
  end

  def call
    csv_data = CsvFetcher.call(@csv_url)
    coffee_shops = CoffeeShopParser.call(csv_data)

    shops_with_distance = coffee_shops.map do |shop|
      distance = DistanceCalculator.call(
        x1: @user_x, y1: @user_y,
        x2: shop.x, y2: shop.y
      )
      { coffee_shop: shop, distance: distance }
    end

    shops_with_distance
      .sort_by { |item| item[:distance] }
      .first(3)
  end
end
