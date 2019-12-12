# frozen_string_literal: true

require 'httparty'

module FAAOISAPI
  class Airport
    def initialize(iata)
      @airport = iata
    end

    def full_name
      fetch_iflightplanner_data do |body|
        Nokogiri::HTML(body).xpath('//div[@class="LocationName"]')
                .inner_text
                .gsub(/^(.*) -.*/, '\1')
                .gsub(/INTL$/, 'International Airport')
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

    private

    def fetch_iflightplanner_data
      response =
        HTTParty.get('https://www.iflightplanner.com/Airports/' + @airport)
      if response.code != 200
        FAAOISAPI.logger.error \
          "Couldn't get airport data for #{airport}: #{response.body}"
        yield(nil)
      end
      yield(response.body)
    end
  end
end
