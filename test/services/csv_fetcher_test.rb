# frozen_string_literal: true

require "test_helper"

class CsvFetcherTest < ActiveSupport::TestCase
  TEST_URL = "https://example.com/coffee_shops.csv"

  test "fetches CSV data successfully" do
    csv_content = "Name,X,Y\nStarbucks,47.5,-122.3"
    stub_request(:get, TEST_URL).to_return(status: 200, body: csv_content)

    result = CsvFetcher.call(TEST_URL)

    assert_equal csv_content, result
  end

  test "raises FetchError on network error" do
    stub_request(:get, TEST_URL).to_raise(SocketError.new("Network error"))

    error = assert_raises(CsvFetcher::FetchError) do
      CsvFetcher.call(TEST_URL)
    end

    assert_match(/network error/i, error.message)
  end

  test "raises FetchError on timeout" do
    stub_request(:get, TEST_URL).to_timeout

    error = assert_raises(CsvFetcher::FetchError) do
      CsvFetcher.call(TEST_URL)
    end

    assert_match(/timeout/i, error.message)
  end

  test "raises FetchError on non-200 response" do
    stub_request(:get, TEST_URL).to_return(status: 404, body: "Not Found")

    error = assert_raises(CsvFetcher::FetchError) do
      CsvFetcher.call(TEST_URL)
    end

    assert_match(/404/i, error.message)
  end

  test "raises FetchError on 500 server error" do
    stub_request(:get, TEST_URL).to_return(status: 500, body: "Internal Server Error")

    error = assert_raises(CsvFetcher::FetchError) do
      CsvFetcher.call(TEST_URL)
    end

    assert_match(/500/i, error.message)
  end

  test "handles redirect responses" do
    redirect_url = "https://example.com/redirected.csv"
    csv_content = "Name,X,Y\nStarbucks,47.5,-122.3"

    stub_request(:get, TEST_URL).to_return(status: 302, headers: { "Location": redirect_url })
    stub_request(:get, redirect_url).to_return(status: 200, body: csv_content)

    result = CsvFetcher.call(TEST_URL)

    assert_equal csv_content, result
  end
end
