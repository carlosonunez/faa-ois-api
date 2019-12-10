# frozen_string_literal: true

require 'spec_helper'

describe 'Given the FAA OIS page' do
  context 'When I fetch it' do
    example 'It condenses the page into a really nice YAML file', :unit do
      expected_output_yml = 'spec/fixtures/example_parsed_ois_info.yml'
      allow(HTTParty).to receive(:get)
        .with($expected_ois_page_url)
        .and_yield(double(HTTParty::Response,
                          code: 200,
                          body: File.read($expected_ois_page)))
      expected_output = YAML.safe_load(File.read(expected_output_yml),
                                       symbolize_names: true)
      actual_output = FAAOISAPI::Page.parse
      %i[programs ground_stops delays closures].each do |section|
        expect(actual_output[section]).to eq expected_output[section]
      end
    end
  end
end
