# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'yaml'

module FAAOISAPI
  module ARTCC
    def self.fetch_info(identifier)
      all_centers = fetch_centers
      matching_center = get_center_info(identifier, all_centers)
      return nil if matching_center.nil || matching_center.empty?

      %i[first_tier second_tier].each do |key|
        matching_center[key] = expand_centers(matching_center[key],
                                              all_centers)
      end
      matching_center
    end

    def self.fetch_centers
      unless File.exist? 'include/artcc_info.yml'
        FAAOISAPI.logger.error 'ARTCC info not found.'
        return nil
      end

      YAML.safe_load(File.read('include/artcc_info.yml'),
                     symbolize_names: true)
    end

    def self.get_center_info(identifier, all_centers, include_tiers: true)
      found = all_centers.find { |datum| datum[:center] == identifier.upcase }
      found.reject! { |key| key.to_s.match?(/_tier$/) } unless include_tiers
      found
    end

    def self.expand_centers(center_identifiers, all_centers)
      center_identifiers.each_with_object([]) do |center, expanded_centers|
        expanded_centers << get_center_info(center,
                                            all_centers,
                                            include_tiers: false)
        expanded_centers
      end
    end

    private_class_method :expand_centers
    private_class_method :get_center_info
    private_class_method :fetch_centers
  end
end
