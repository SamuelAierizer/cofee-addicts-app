# frozen_string_literal: true

require "csv"

class CoffeeShopParser
  def self.call(csv_data)
    new(csv_data).call
  end

  def initialize(csv_data)
    @csv_data = csv_data
  end

  def call
    return [] if @csv_data.nil? || @csv_data.strip.empty?

    coffee_shops = []

    CSV.parse(@csv_data, headers: true) do |row|
      next unless valid_row?(row)

      coffee_shops << build_coffee_shop(row)
    rescue ArgumentError, TypeError => e
      Rails.logger.warn("Skipping malformed CSV row: #{e.message}")
      next
    end

    coffee_shops
  end

  private

  def valid_row?(row)
    return false if row.nil?
    return false if row["Name"].nil? || row["Name"].to_s.strip.empty?
    return false if row["X"].nil? || row["Y"].nil?
    return false unless numeric?(row["X"]) && numeric?(row["Y"])

    true
  end

  def numeric?(value)
    return false if value.nil? || value.to_s.strip.empty?

    Float(value.to_s.strip)
    true
  rescue ArgumentError, TypeError
    false
  end

  def build_coffee_shop(row)
    CoffeeShop.new(
      name: row["Name"].to_s.strip,
      x: row["X"].to_s.strip,
      y: row["Y"].to_s.strip
    )
  end
end
