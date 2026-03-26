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
