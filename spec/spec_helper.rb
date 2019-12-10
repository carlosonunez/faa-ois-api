# frozen_string_literal: true

require 'yaml'
require 'httparty'
require 'faa_ois_api'

RSpec.configure do |config|
  config.before(:all, unit: true) do
    extend RSpec::Mocks::ExampleMethods
    $expected_ois_page = 'spec/fixtures/example_ois_page.html'
    $expected_ois_page_url = ENV['FAA_OIS_URL'] ||
                             'https://www.fly.faa.gov/ois/jsp/summary_sys.jsp'
  end
end
