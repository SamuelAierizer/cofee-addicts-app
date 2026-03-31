# frozen_string_literal: true

class Rack::Attack
  # Throttle all requests by IP (60rpm)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle API requests by IP
  throttle("api/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  # Throttle specific endpoint more aggressively
  throttle("coffee_shops/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/coffee_shops/nearest"
  end

  # Block requests from known bad actors
  blocklist("block bad IPs") do |req|
    # Add IPs to block here if needed
    # Example: Rack::Attack::Allow2Ban.filter("pentesters-#{req.ip}", maxretry: 5, findtime: 10.minutes, bantime: 1.hour) do
    #   req.path.include?("admin") || req.path.include?("wp-admin")
    # end
    false
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = env["rack.attack.match_data"][:period]
    [
      429,
      {
        "Content-Type" => "application/json",
        "Retry-After" => retry_after.to_s
      },
      [{ errors: [{ detail: "Rate limit exceeded. Try again in #{retry_after} seconds." }] }.to_json]
    ]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |_env|
    [
      403,
      { "Content-Type" => "application/json" },
      [{ errors: [{ detail: "Forbidden" }] }.to_json]
    ]
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack
