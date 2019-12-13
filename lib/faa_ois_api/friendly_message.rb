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
      render_template(template_vars)[:ground_stop][:no_affected_areas]
    end

    def self.render_template(template_vars)
      template = Loader.new
      template.render(template_vars)
    end

    private_class_method :generate_ground_stop_message
    private_class_method :render_template
  end
end
