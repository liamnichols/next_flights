require "erb"

class Generator
  attr_reader :offers, :dates, :updated_at

  def initialize(offers:, dates:, updated_at:)
    @offers = offers
    @dates = dates
    @updated_at = updated_at
  end

  def generate(locale: :en)
    @current_locale = locale
    result = [current_page[:filename], template.result(binding)]
    @current_locale = nil

    result
  end

  def t(key, **options)
    I18n.t(key, locale: @current_locale, **options)
  end

  def updated_date
    updated_at&.strftime("%Y-%m-%d")
  end

  def updated_time
    updated_at&.strftime("%H:%M")
  end

  def link_to(content, href, **options)
    target = options[:target] || "_blank"

    "<a class=\"#{options[:class]}\" target=\"#{target}\" href=\"#{href}\">#{content}</a>"
  end

  def donate_link
    link_to t("index.donate.link"), "https://donate.redcrossredcrescent.org/lb/supportLRC", class: "inline font-medium underline underline-offset-2 decoration-600 decoration-solid hover:no-underline"
  end

  def mea_link
    link_to "mea.com.lb", "https://mea.com.lb", class: "inline font-medium underline underline-offset-2 decoration-600 decoration-solid hover:no-underline"
  end

  def span(content, **options)
    klass = options[:class] || "font-bold"

    "<span class=\"#{klass}\">#{content}</span>"
  end

  def current_page
    PAGES.fetch(@current_locale)
  end

  def alternative_page
    PAGES.fetch(current_page[:alternate_locale])
  end

  def default_page
    PAGES.fetch(:en)
  end

  private

    PAGES = {
      en: {
        filename: "index.html",
        href: "https://next-flights.fyi",
        locale: :en,
        dir: "ltr",
        alternate_locale: :ar
      },
      ar: {
        filename: "index.ar.html",
        href: "https://next-flights.fyi/index.ar.html",
        locale: :ar,
        dir: "rtl",
        alternate_locale: :en
      }
    }.freeze

    def template
      ERB.new(File.read(template_path))
    end

    def template_path
      File.expand_path("../../../resources/index.html.erb", __FILE__)
    end
end
