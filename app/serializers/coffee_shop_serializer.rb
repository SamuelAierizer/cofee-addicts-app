# frozen_string_literal: true

class CoffeeShopSerializer
  include JSONAPI::Serializer

  set_type :coffee_shop
  attributes :name, :x, :y

  attribute :distance do |object, params|
    params[:distance]
  end

  def self.serialize_collection(results)
    data = results.map.with_index do |result, index|
      shop = result[:coffee_shop]
      distance = result[:distance]

      {
        id: (index + 1).to_s,
        type: :coffee_shop,
        attributes: {
          name: shop.name,
          x: shop.x,
          y: shop.y,
          distance: distance
        }
      }
    end

    { data: data }
  end
end
