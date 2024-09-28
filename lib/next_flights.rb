require "i18n"
require "next_flights/version"
require "next_flights/cli"

I18n.load_path += Dir[File.expand_path("resources/locales") + "/*.yml"]
I18n.default_locale = :en

module NextFlights
  class Error < StandardError; end
end
