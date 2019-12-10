# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'time'
require 'yaml'
require 'faa_ois_api/helpers/time'
require 'faa_ois_api/helpers/html'

module FAAOISAPI
  module Page
    def self.parse
      fetch_ois_data do |response|
        return {} if response.nil?

        {
          programs: get_programs_table(response.body),
          ground_stops: get_ground_stops_table(response.body),
          delays: get_delays_table(response.body),
          closures: get_closures_table(response.body)
        }
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # This is literally a transplant of the National Programs table with
    # some decorator methods added to prettify the output. Breaking this
    # down further to reduce the # of branches or lines wouldn't make sense.
    def self.get_programs_table(html)
      get_table_contents(html, 'NATIONAL PROGRAMS')
        .each_with_object([]) do |program_found, programs_to_return|
        programs_to_return << {
          airport_or_zone_name: program_found[1],
          program_start: FAAOISAPI::Helpers::Time.parse(program_found[2]),
          program_end: FAAOISAPI::Helpers::Time.parse(program_found[3]),
          areas_affected: program_found[4].split('+').map(&:strip),
          reasons: program_found[5].split('/').map(&:strip),
          average_delays_in_minutes: program_found[6].to_i,
          airport_acceptance_rate: program_found[7].to_i,
          program_mandated_acceptance_rate: program_found[8].to_i
        }
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def self.get_ground_stops_table(html)
      get_table_contents(html, 'GROUND STOPS')
        .each_with_object([]) do |ground_stop, ground_stops_to_return|
        ground_stops_to_return << {
          airport: ground_stop[1],
          last_update_time: FAAOISAPI::Helpers::Time.parse(ground_stop[2]),
          probability_of_extension: ground_stop[3],
          areas_affected: ground_stop[4].split('+').map(&:strip),
          reasons: ground_stop[5].split('/').map(&:strip)
        }
      end
    end

    def self.get_delays_table(html)
      get_table_contents(html, 'DELAY INFO')
        .each_with_object([]) do |delay, delays_to_return|
        delays_to_return << {
          airport: delay[1],
          arrival_delay_minutes: delay[2].to_i || 0,
          departure_delay_minutes: delay[3].to_i || 0,
          last_updated_time: FAAOISAPI::Helpers::Time.parse(delay[4]),
          reasons: delay[5].split('/').map(&:strip)
        }
      end
    end

    def self.get_closures_table(html)
      get_table_contents(html, 'AIRPORT CLOSURES')
        .each_with_object([]) do |closure, closures|
        closure = closure.compact # Got a ton of `nil` elements during tests
        closures << {
          airport: closure[0],
          closure_time: FAAOISAPI::Helpers::Time.parse_relative(closure[1]),
          reasons: closure[2].split('/').map(&:strip),
          reopen_time: FAAOISAPI::Helpers::Time.parse_relative(closure[3])
        }
      end
    end

    def self.get_table_contents(html, header_title)
      xpath_query = FAAOISAPI::Helpers::HTML.create_xpath_query(header_title)
      Nokogiri::HTML(html).xpath(xpath_query).map do |row|
        next if row.inner_text.match?(/#{header_title.upcase}|REASON/)

        row.inner_text.split("\n").map do |element|
          element.strip.empty? ? nil : element
        end
      end.compact
    end

    def self.fetch_ois_data
      @faa_ois_url = ENV['FAA_OIS_URL'] ||
                     'https://www.fly.faa.gov/ois/jsp/summary_sys.jsp'
      HTTParty.get(@faa_ois_url) do |response|
        if response.code != 200
          FAAOISAPI.logger.error "Failed to capture OIS data: #{response.body}"
          yield(nil)
        else
          yield(response)
        end
      end
    end

    private_class_method :get_ground_stops_table
    private_class_method :get_programs_table
    private_class_method :get_delays_table
    private_class_method :get_table_contents
    private_class_method :fetch_ois_data
  end
end
