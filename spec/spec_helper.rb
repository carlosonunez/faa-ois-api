# frozen_string_literal: true

require 'yaml'
require 'httparty'
require 'faa_ois_api'

RSpec.configure do |config|
  config.before(:all, unit: true) do
    extend RSpec::Mocks::ExampleMethods
    $expected_ois_page = 'spec/fixtures/example_ois_page.html'
    $expected_iflightplanner_html =
      'spec/fixtures/example_iflightplanner_response.html'
    $iflightplanner_url = 'https://www.iflightplanner.com/Airports/DFW'
    $expected_ois_page_url = ENV['FAA_OIS_URL'] ||
                             'https://www.fly.faa.gov/ois/jsp/summary_sys.jsp'
    $expected_output_yml = 'spec/fixtures/example_parsed_ois_info.yml'
  end
end
