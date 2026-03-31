# frozen_string_literal: true

Rails.application.configure do
  config.coffee_shops_csv_url = ENV.fetch(
    "COFFEE_SHOPS_CSV_URL",
    "https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv"
  )
end
