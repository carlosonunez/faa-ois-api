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

  context 'When a national program is in place' do
    context 'And no other areas are affected' do
      example 'Then I get a friendly message describing it', :unit do
        allow(FAAOISAPI::Airport).to receive(:new)
          .and_return(double(FAAOISAPI::Airport,
                             full_name: 'Newark-Liberty International'))
        allow(FAAOISAPI).to receive(:parse).and_return(example_output)
        ewr_ground_stop =
          example_output[:programs]
          .find { |program| program[:airport_or_zone_name] == 'EWR' }
        ewr_ground_stop[:areas_affected] = []
        expected_friendly_message = <<~FRIENDLY_MESSAGE.chomp
          Newark-Liberty International (EWR) is currently experiencing a ground \
          stop that's expected to end at 03:59 UTC. \
          Try using another airport nearby, as this is the only airport \
          affected by this.
        FRIENDLY_MESSAGE
        expect(FAAOISAPI::FriendlyMessage.generate(type: :program,
                                                   data: ewr_ground_stop))
          .to eq expected_friendly_message
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
