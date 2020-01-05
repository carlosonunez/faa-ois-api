# frozen_string_literal: true

require 'yaml'
require 'faa_ois_api/friendly_message/loader'

module FAAOISAPI
  module FriendlyMessage
    def self.generate(type:, data:)
      case type
      when :program
        generate_ground_stop_message(data)
      when :delay
        nil
      when :closure
        nil
      else
        raise NameError, "Invalid info type: #{type}"
      end
    end

    def self.generate_ground_stop_message(data)
      airport = Airport.new(data[:airport_or_zone_name])
      template_vars = {
        airport: airport.full_name,
        airport_iata: airport.iata,
        end_time: data[:program_end]
      }
      template_vars[:affected_areas] = get_affected data[:areas_affected]
      render_template(template_vars)[:ground_stop]
    end

    def self.render_template(template_vars)
      template = Loader.new
      template.render(template_vars)
    end

    def self.get_affected(affected_list)
      affected_list.each_with_object([]) do |item, accumulator|
        airport_info = Airport.new(item)
        artcc_info = ARTCC.fetch_info(item)
        if airport_info.valid_airport?
          accumulator << "- #{airport_info.full_name}"
        elsif !artcc_info.nil?
          accumulator << "- some (or all) of the #{artcc_info[:friendly]} area"
        else
          FAAOISAPI.logger.warn "Don't know what affect this is: #{item}"
          accumulator << "- #{item}"
        end
      end
    end

    private_class_method :generate_ground_stop_message
    private_class_method :render_template
  end
end
