# frozen_string_literal: true

require 'yaml'
require 'httparty'
require 'faa_ois_api'
require 'yaml'

module TestMocks
  def self.generate!
    extend RSpec::Mocks::ExampleMethods
    YAML.safe_load(File.read('spec/include/mocks.yml'),
                   symbolize_names: true).each do |mock|
      mocked_body_file = "spec/fixtures/#{mock[:page]}"
      allow(HTTParty)
        .to receive(:get)
        .with(mock[:url])
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read(mocked_body_file)))
    end
  end
end
