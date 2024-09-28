require_relative "amadeus/client"
require_relative "destination"
require_relative "generator"
require "tzinfo"

module NextFlights
  class CLI
    attr_reader :offers, :updated_at

    def self.start(args)
      self.new.run(args.first)
    end

    def run(output_path)
      summarize

      fetch_offers
      puts "Found #{offers.length} offers"

      puts "Generating html..."
      generator = Generator.new(offers:, dates:, updated_at:)
      %i(en ar).each do |locale|
        filename, html = generator.generate(locale:)
        filepath = File.join(output_path, filename)

        puts "Writing html to '#{filepath}'"
        File.write(filepath, html)
      end
    end

    def html
      @_html ||= template.result(binding)
    end

    def template
      @_template ||= ERB.new(File.read(File.expand_path("../../../resources/index.html.erb", __FILE__)))
    end

    def fetch_offers
      @updated_at = beirut.now
      @offers = client.all_offers(destinations:, dates:).sort_by(&:sort_value)
    end

    def client
      @_client ||= Amadeus::Client.new
    end

    def destinations
      Destination.all
    end

    def dates
      return @dates if defined?(@dates)

      now = beirut.now
      today = Date.new(now.year, now.month, now.day)

      start_date = if beirut.now.hour > 4
        today + 1 # tomorrow
      else
        today
      end

      @dates = 6.times.map { start_date + _1 }
    end

    def beirut
      @_beirut ||= TZInfo::Timezone.get("Asia/Beirut")
    end

    def summarize
      puts "Search Criteria:"
      puts "  Dates:"
      dates.each do |date|
        puts "    - #{date}"
      end
      puts "  Destinations:"
      destinations.each do |destination|
        puts "    - #{destination.to_s}"
      end
    end
  end
end
