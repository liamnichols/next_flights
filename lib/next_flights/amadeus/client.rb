require "oauth2"
require_relative "flight_availabilities"
require_relative "flight_offers"

module Amadeus
  class Client < OAuth2::Client
    def initialize(api_key = ENV.fetch("API_KEY"), api_secret = ENV.fetch("API_SECRET"), options = {})
      # Set a default token_url if not provided in options
      options[:site] ||= ENV["BASE_URL"]
      options[:token_url] ||= "v1/security/oauth2/token"

      # Call the parent class initializer with the defaults and options
      super(api_key, api_secret, options)
    end

    def flight_availabilities(destination:, dates:)
      destination = Destination.find(destination) if destination.kind_of?(String)

      FlightAvailabilities::Search.new(client: self, destination:, dates:)
        .response
        .availability
    end

    def flight_offers(destination:, date:)
      destination = Destination.find(destination) if destination.kind_of?(String)

      FlightOffers::Search.new(client: self, destination:, date:)
        .response
        .offers
    end

    def current_token
      # TODO: Refresh...
      @_current_token ||= client_credentials.get_token
    end

    def all_offers(destinations: Destination.all, dates:)
      all_offers = []

      destinations.each do |destination|
        puts "Fetching availability for #{destination.name}..."
        available_dates = flight_availabilities(destination:, dates:).map(&:departure_date).uniq

        if available_dates.empty?
          puts "  No availability"
          next
        end

        available_dates.each do |date|
          flight_offers(destination:, date:).each do |offer|
            all_offers << offer
            puts "  #{offer.departure_date}: #{offer.carrier_code + offer.flight_number} @ #{offer.departure_time} - #{offer.seats} seat starting from #{offer.price} USD (#{offer.cabin})"
          end
        end
      end

      all_offers.sort_by(&:sort_value)
    end
  end
end
