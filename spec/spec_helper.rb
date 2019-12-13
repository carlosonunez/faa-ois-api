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
      allow(HTTParty)
        .to receive(:get)
        .with(mock[:url])
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read("spec/fixtures/#{mock[:page]}")))
    end
  end
end
