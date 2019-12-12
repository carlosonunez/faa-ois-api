# frozen_string_literal: true

require 'yaml'
require 'httparty'
require 'faa_ois_api'

module TestMocks
  MOCKS = {
    'iflightplanner.com/Airports/DFW': 'example_iflightplanner_response',
    'fly.faa.gov/ois/jsp/summary_sys.jsp': 'example_ois_page'
  }.freeze
  def self.generate_mocks!
    extend RSpec::Mocks::ExampleMethods
    MOCKS.each do |url, mocked_body|
      mocked_body_file = "spec/fixtures/#{mocked_body}.html"
      allow_any_instance_of(HTTParty)
        .to receive(url)
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read(mocked_body_file)))
    end
  end
end
