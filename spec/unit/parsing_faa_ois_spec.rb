# frozen_string_literal: true

require 'spec_helper'

# Disable this for specs since there are a lot of scenarios
# that I would like to cover within the same spec.
# rubocop:disable Metrics/BlockLength
describe 'Given the FAA OIS page' do
  before(:each) { TestMocks.generate! }

  let(:expected_output) do
    YAML.safe_load(File.read('spec/fixtures/example_parsed_ois_info.yml'),
                   symbolize_names: true)
  end

  context 'When I fetch it' do
    example 'It condenses the page into a really nice YAML file', :unit do
      actual_output = FAAOISAPI::Page.parse
      %i[programs ground_stops delays closures].each do |section|
        expect(actual_output[section]).to eq expected_output[section]
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
