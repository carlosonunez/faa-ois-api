# frozen_string_literal: true

require 'time'

module FAAOISAPI
  module Helpers
    module Time
      def self.parse(time_string)
        return nil if time_string.nil?

        if !time_string.match?(/^[0-9]{4}$/)
          FAAOISAPI.logger.error "Invalid time: #{time_string}"
        else
          time_string.gsub(/^([0-9]{2})([0-9]{2})$/, '\1:\2')
        end
      end

      # Airport closures are reported in a weird relative date format
      # that doesn't include the year. Fix this so that it reports this in
      # Unix time.
      def self.parse_relative(time_string)
        return nil if time_string.nil? ||
                      time_string.empty? ||
                      time_string == 'UNKNOWN'

        new_time_properties = [Date.today.year]
        time_string.scan(/^(..)(..)(..)(..)$/).each do |number|
          new_time_properties << number
        end.flatten # since capturing groups are inserted into an array
        ::Time.new(*new_time_properties.flatten.map(&:to_i)).to_i
      rescue ArgumentError => e
        FAAOISAPI.logger.error "Failed at converting #{time_string}: #{e}"
      end
    end
  end
end
