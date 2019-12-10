# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

module FAAOISAPI
  module Airports
    def self.get_artcc(airport)
      fetch_iflightplanner_data(airport) do |body|
        Nokogiri::HTML(body).xpath('//label[contains(., "ARTCC")]//..//div')
                .inner_text
                .gsub(/^(.*) -.*/, '\1')
      end
    end

    def self.fetch_iflightplanner_data(airport)
      response =
        HTTParty.get('https://www.iflightplanner.com/Airports/' + airport)
      if response.code != 200
        FAAOISAPI.logger.error \
          "Couldn't get airport data for #{airport}: #{response.body}"
        yield(nil)
      end
      yield(response.body)
    end
  end
end
