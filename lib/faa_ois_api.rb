# frozen_string_literal: true

require 'faa_ois_api/page'
require 'faa_ois_api/airport'
require 'faa_ois_api/artcc'
require 'faa_ois_api/friendly_message'

module FAAOISAPI
  @logger = Logger.new(STDOUT)
  @logger.level = ENV['LOG_LEVEL'] || Logger::WARN
  def self.logger
    @logger
  end
end
