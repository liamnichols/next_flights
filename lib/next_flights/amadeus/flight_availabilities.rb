module Amadeus
  module FlightAvailabilities
    class Availability
      attr_reader :duration, :carrier_code, :flight_number, :departs_at, :availability_classes

      def initialize(data)
        @duration = data.dig("duration")
        @carrier_code = data.dig("segments", 0, "carrierCode"),
        @flight_number = data.dig("segments", 0, "number")
        @departs_at = data.dig("segments", 0, "departure", "at")
        @availability_classes = data.dig("segments", 0, "availabilityClasses")

        @carrier_code = @carrier_code.first if @carrier_code.kind_of?(Array)
      end

      def departure_date
        departs_at.split("T").first
      end

      def departure_time
        departs_at.split("T").last[0...5]
      end
    end

    class Response
      attr_reader :body
      def initialize(body)
        @body = body
      end

      def availability
        @_offers ||= data
          .map { Availability.new(_1) }
          .sort_by(&:departs_at)
      end

      private

        def data
          @_data ||= JSON.parse(body).dig("data") || []
        end
    end

    class Search
      attr_reader :client, :destination, :dates

      def initialize(client:, destination:, dates:)
        @client = client
        @destination = destination
        @dates = dates
      end

      def response
        Response.new(fetch_response.body)
      end

      private

        def fetch_response
          client.current_token.post("v1/shopping/availability/flight-availabilities", headers:, body:)
        end

        def origin_destinations
          dates.each_with_index.map do |date, id|
            {
              id: "#{id}",
              originLocationCode: "BEY",
              destinationLocationCode: destination.iata_code,
              departureDateTime: {
                date: date
              }
            }
          end
        end

        def body
          {
            originDestinations: origin_destinations,
            travelers: [ { id: "1", travelerType: "ADULT" } ],
            sources: [ "GDS" ],
            searchCriteria: {
              includeClosedContent: false,
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
