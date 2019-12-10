# frozen_string_literal: true

require 'faa_ois_api/page'

module FAAOISAPI
  @logger = Logger.new(STDOUT)
  @logger.level = ENV['LOG_LEVEL'] || Logger::WARN
  def self.logger
    @logger
  end
end
