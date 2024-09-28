require "json"

class Destination
  EXCLUDED_DESTINATIONS = %w(YTO)

  attr_reader :iata_code, :name, :relevance, :type

  def initialize(data)
    @iata_code = data.dig("iataCode")
    @name = data.dig("name")
    @relevance = data.dig("metrics", "relevance")
    @type = data.dig("subtype").to_sym
  end

  def self.all
    lookup.values
  end

  def self.find(iata_code)
    lookup.fetch(iata_code) { raise "No known destination for '#{iata_code}'" }
  end

  def to_s
    "#{name} (#{iata_code})"
  end

  private

    def self.lookup
      @_lookup ||= JSON
        .parse(File.read(resource_path))
        .dig("data")
        .map { Destination.new(_1) }
        .reject { EXCLUDED_DESTINATIONS.include?(_1.iata_code) }
        .sort_by(&:relevance)
        .reverse
        .map { [_1.iata_code, _1] }
        .to_h
    end

    def self.resource_path
      File.expand_path("../../../resources/destinations.json", __FILE__)
    end
end
