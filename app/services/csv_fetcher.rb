# frozen_string_literal: true

require "net/http"
require "uri"

class CsvFetcher
  class FetchError < StandardError; end

  TIMEOUT_SECONDS = 10
  MAX_REDIRECTS = 5

  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = url
  end

  def call
    fetch_with_redirects(@url, MAX_REDIRECTS)
  rescue SocketError, Errno::ECONNREFUSED => e
    raise FetchError, "Network error: #{e.message}"
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise FetchError, "Timeout: #{e.message}"
  end

  private

  def fetch_with_redirects(url, redirects_remaining)
    uri = URI.parse(url)
    response = make_request(uri)

    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      raise FetchError, "Too many redirects" if redirects_remaining <= 0

      fetch_with_redirects(response["location"], redirects_remaining - 1)
    else
      raise FetchError, "HTTP #{response.code}: #{response.message}"
    end
  end

  def make_request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = TIMEOUT_SECONDS
    http.read_timeout = TIMEOUT_SECONDS

    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end
end
