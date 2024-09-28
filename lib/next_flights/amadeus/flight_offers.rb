module Amadeus
  module FlightOffers
    class Offer
      attr_reader :seats, :price, :cabin, :validating_airline_codes, :duration, :carrier_code, :flight_number, :departs_at, :destination, :arrival_iata_code

      def initialize(data, destination)
        @seats = data.dig("numberOfBookableSeats")
        @price = data.dig("travelerPricings", 0, "price", "total")
        @cabin = data.dig("travelerPricings", 0, "fareDetailsBySegment", 0, "cabin")
        @validating_airline_codes = data.dig("validatingAirlineCodes")
        @duration = data.dig("itineraries", 0, "duration")
        @carrier_code = data.dig("itineraries", 0, "segments", 0, "carrierCode")
        @flight_number = data.dig("itineraries", 0, "segments", 0, "number")
        @departs_at = data.dig("itineraries", 0, "segments", 0, "departure", "at")
        @destination = destination
        @arrival_iata_code = data.dig("itineraries", 0, "segments", 0, "arrival", "iataCode")

        @carrier_code = @carrier_code.first if @carrier_code.kind_of?(Array)
      end

      def departure_date
        departs_at.split("T").first
      end

      def departure_time
        departs_at.split("T").last[0...5]
      end

      def sort_value
        "#{departs_at}_#{destination.name}"
      end
    end

    class Response
      attr_reader :body, :destination

      def initialize(body, destination)
        @body = body
        @destination = destination
      end

      def offers
        @_offers ||= data
          .map { Offer.new(_1, destination) }
          .select { _1.validating_airline_codes.include?("ME") }
          .sort_by(&:departs_at)
      end

      private

        def data
          @_data ||= JSON.parse(body).dig("data") || []
        end
    end

    class Search
      attr_reader :client, :destination, :date

      def initialize(client:, destination:, date:)
        @client = client
        @destination = destination
        @date = date
      end

      def response
        Response.new(fetch_response.body, destination)
      end

      private

        def fetch_response
          client.current_token.post("v2/shopping/flight-offers", headers:, body:)
        end

        def origin_destinations
          [
            {
              id: "1",
              originLocationCode: "BEY",
              destinationLocationCode: destination.iata_code,
              departureDateTimeRange: {
                date: date
              }
            }
          ]
        end

        def body
          {
            originDestinations: origin_destinations,
            travelers: [ { id: "1", travelerType: "ADULT" } ],
            sources: [ "GDS" ],
            searchCriteria: {
              flightFilters: {
                connectionRestriction: { maxNumberOfConnections: 0 },
                carrierRestrictions: { includedCarrierCodes: [ "ME" ]}
              }
            }
          }.to_json
        end

      def headers
        { "Content-Type" => "application/json" }
      end
    end
  end
end
