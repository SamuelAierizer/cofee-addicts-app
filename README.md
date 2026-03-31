# Coffee Addicts API

A REST API that finds the three closest coffee shops to a user's location.

Application build for a coding challenge.

## Problem Description

You have been hired by a company that builds an app for coffee addicts. You are responsible for writing a REST API that offers the possibility to take the user's  coordinates and return a list of the three closest coffee shops (including distance from the user) in order from the closest to farthest.

### Data

The coffee shops are stored in a remote CSV having these columns: Name,X,Y
The quality of data in this list of coffee shops may vary. Malformed entries should be handled appropriately.
Notice that the data file will be read from a network location (ex:
https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv )

### API Specification

A list of the three closest coffee shops (name, location and distance from the user) in order from the closest to farthest.
These distances should be rounded to four decimal places.
Assume all coordinates lie on a plane.
Use JSON API Specification for client requests and server responses.

### Example

For coordinates `X=47.6` and `Y=-122.4`, the response contains:
1. Starbucks Seattle2
2. Starbucks Seattle
3. Starbucks SF

## Requirements

- Ruby 3.3+
- Rails 8.1+

## Setup

```bash
bundle install
```

## Running the Server

```bash
bin/rails server
```

## API Documentation

Note: Swagger was considered but not implemented due to time constraints and the simplicity of the API.

### Endpoint: Get Nearest Coffee Shops

**URL:** `GET /api/v1/coffee_shops/nearest`

**Description:** Returns the 3 closest coffee shops to the user's coordinates, sorted by distance (closest first).

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `x` | Float | Yes | User's X coordinate on the plane |
| `y` | Float | Yes | User's Y coordinate on the plane |

#### Example Request

```bash
curl "http://localhost:3000/api/v1/coffee_shops/nearest?x=47.6&y=-122.4"
```

#### Success Response (200 OK)

```json
{
  "data": [
    {
      "id": "1",
      "type": "coffee_shop",
      "attributes": {
        "name": "Blue Bottle",
        "x": 47.6205,
        "y": -122.3493,
        "distance": 0.0547
      }
    },
    {
      "id": "2",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks Seattle2",
        "x": 47.5869,
        "y": -122.3368,
        "distance": 0.0645
      }
    },
    {
      "id": "3",
      "type": "coffee_shop",
      "attributes": {
        "name": "Peets Coffee",
        "x": 47.6062,
        "y": -122.3321,
        "distance": 0.0682
      }
    }
  ]
}
```

#### Error Responses

**400 Bad Request** - Missing or invalid parameters

```json
{
  "errors": [
    {
      "detail": "param is missing or the value is empty: x"
    }
  ]
}
```

**429 Too Many Requests** - Rate limit exceeded

```json
{
  "errors": [
    {
      "detail": "Rate limit exceeded. Try again in 60 seconds."
    }
  ]
}
```

**503 Service Unavailable** - External CSV service unavailable

```json
{
  "errors": [
    {
      "detail": "Service unavailable: Network error"
    }
  ]
}
```

### Rate Limiting

The API implements the following rate limits per IP address:

- **General API requests:** 30 requests per minute
- **Coffee shops endpoint:** 20 requests per minute

When rate limited, the response includes a `Retry-After` header indicating when to retry.

### Features

- **JSON:API Compliant** - Follows JSON:API specification for responses
- **Malformed Data Handling** - Gracefully skips invalid CSV entries
- **Rate Limiting** - Rack::Attack protection against abuse
- **Caching** - CSV data cached for 1 hour to improve performance
- **Error Handling** - Comprehensive error responses with proper HTTP status codes
- **Security** - Brakeman and Bundler Audit clean
- **Test Coverage** - 61 tests with 234 assertions

## Testing

Run the full test suite:

```bash
bin/rails test
```

Run specific test files:

```bash
bin/rails test test/controllers/api/v1/coffee_shops_controller_test.rb
bin/rails test test/integration/nearest_coffee_shops_api_test.rb
```

## Code Quality

Run linting:

```bash
bundle exec rubocop
```

Run security scans:

```bash
bundle exec brakeman
bundle exec bundler-audit check --update
```

## Configuration

The CSV data source URL can be configured via environment variable:

```bash
export COFFEE_SHOPS_CSV_URL="https://your-csv-url.com/coffee_shops.csv"
```

Default: `https://raw.githubusercontent.com/Agilefreaks/test_oop/master/coffee_shops.csv`

## Architecture

The application follows clean architecture principles with:

- **Controllers** - Thin controllers handling HTTP concerns
- **Services** - Business logic encapsulated in service objects
  - `CsvFetcher` - Fetches CSV data with caching and error handling
  - `CoffeeShopParser` - Parses CSV and validates data
  - `DistanceCalculator` - Calculates Euclidean distance
  - `NearestCoffeeShopsFinder` - Orchestrates finding nearest shops
- **Models** - Plain Old Ruby Objects (POROs)
  - `CoffeeShop` - Represents a coffee shop entity
- **Serializers** - JSON:API compliant serialization
  - `CoffeeShopSerializer` - Formats response data

## CI/CD

GitHub Actions workflow runs on every push and pull request:

- RuboCop linting
- Brakeman security scanning
- Bundler Audit dependency checks
- Full test suite

## License

MIT
