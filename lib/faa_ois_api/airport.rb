# frozen_string_literal: true

require 'httparty'

module FAAOISAPI
  class Airport
    def initialize(iata)
      @airport = iata
      @airport_data = nil
    end

    def full_name
      fetch_iflightplanner_data do |body|
        Nokogiri::HTML(body).xpath('//div[@class="LocationName"]')
                .inner_text
                .gsub(/^(.*) -.*/, '\1')
                .gsub(/INTL$/, 'International')
                .gsub(/\w+/, &:capitalize)
      end
    end

    def artcc
      fetch_iflightplanner_data do |body|
        Nokogiri::HTML(body).xpath('//label[contains(., "ARTCC")]//..//div')
                .inner_text
                .gsub(/^(.*) -.*/, '\1')
      end
    end

    def valid_airport?
      fetch_iflightplanner_data.nil?
    end

    # Convenient decorator so that we don't have to keep referring to YAML
    # to get this value.
    def iata
      @airport
    end

    private

    def fetch_iflightplanner_data
      yield(@airport_data) unless @airport_data.nil?

      uri = 'https://www.iflightplanner.com/Airports/' + @airport
      FAAOISAPI.logger.debug "Fetching from iFlightPlanner: #{uri}"
      response = HTTParty.get(uri, follow_redirects: false)
      case response.code
      when 200
        yield(response.body)
      when 302
        FAAOISAPI.logger.warn("Invalid airport: #{@airport}")
        yield(nil)
      else
        FAAOISAPI.logger.error("Failed to get airport for #{@airport}: #{response.body}")
      end
    end
  end
end
