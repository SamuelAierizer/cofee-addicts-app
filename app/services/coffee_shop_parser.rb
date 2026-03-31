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
    lines = @csv_data.lines.map(&:strip).reject(&:empty?)
    return [] if lines.empty?

    # Detect if first line is a header
    has_headers = header_line?(lines.first)
    start_index = has_headers ? 1 : 0

    # Parse each data line
    lines[start_index..-1]&.each do |line|
      next if line.empty?

      fields = CSV.parse_line(line)
      next unless valid_fields?(fields)

      coffee_shops << build_coffee_shop_from_fields(fields)
    rescue ArgumentError, TypeError => e
      Rails.logger.warn("Skipping malformed CSV row: #{e.message}")
      next
    end

    coffee_shops
  end

  private

  def header_line?(line)
    return false if line.nil? || line.empty?

    # Check if line matches "Name,X,Y" pattern (case-insensitive)
    fields = CSV.parse_line(line)
    return false if fields.length < 3

    fields[0].to_s.strip.downcase == "name" &&
      fields[1].to_s.strip.downcase == "x" &&
      fields[2].to_s.strip.downcase == "y"
  end

  def valid_fields?(fields)
    return false if fields.nil? || fields.length < 3
    return false if fields[0].nil? || fields[0].to_s.strip.empty?
    return false unless numeric?(fields[1]) && numeric?(fields[2])

    true
  end

  def numeric?(value)
    return false if value.nil? || value.to_s.strip.empty?

    Float(value.to_s.strip)
    true
  rescue ArgumentError, TypeError
    false
  end

  def build_coffee_shop_from_fields(fields)
    CoffeeShop.new(
      name: fields[0].to_s.strip,
      x: fields[1].to_s.strip,
      y: fields[2].to_s.strip
    )
  end
end
