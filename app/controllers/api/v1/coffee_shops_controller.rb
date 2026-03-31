# frozen_string_literal: true

module Api
  module V1
    class CoffeeShopsController < ApplicationController
      def nearest
        x = Float(params.require(:x))
        y = Float(params.require(:y))

        finder = NearestCoffeeShopsFinder.new(user_x: x, user_y: y)
        results = finder.call

        render json: CoffeeShopSerializer.serialize_collection(results)
      rescue ArgumentError, ActionController::ParameterMissing => e
        render json: { errors: [ { detail: e.message } ] }, status: :bad_request
      rescue CsvFetcher::FetchError => e
        render json: { errors: [ { detail: "Service unavailable: #{e.message}" } ] }, status: :service_unavailable
      end
    end
  end
end
