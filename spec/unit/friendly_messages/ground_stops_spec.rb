# frozen_string_literal: true

require 'spec_helper'

# lots of mocking needed here
# rubocop:disable Metrics/BlockLength
describe 'Given FAA OIS data' do
  let(:example_output) do
    YAML.safe_load(File.read('spec/fixtures/example_parsed_ois_info.yml'),
                   symbolize_names: true)
  end
  before(:each) do
    allow(FAAOISAPI).to receive(:parse).and_return(example_output)
    allow(FAAOISAPI::Airport).to receive(:new)
      .with('EWR')
      .and_return(double(FAAOISAPI::Airport,
                         full_name: 'Newark-Liberty International',
                         iata: 'EWR',
                         valid_airport?: true))
    %w[CZY CZV].each do |icao_airport_code|
      allow(FAAOISAPI::Airport).to receive(:new)
        .with(icao_airport_code)
        .and_return(double(FAAOISAPI::Airport,
                           valid_airport?: false))
    end
  end

  context 'When a national program is in place' do
    let(:ewr_ground_stop) do
      example_output[:programs].find do |program|
        program[:airport_or_zone_name] == 'EWR'
      end
    end

    context 'And no other areas are affected' do
      example 'Then I get a friendly message describing it', :unit do
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

    context 'And other airports are affected' do
      context 'But not all nearby' do
        example 'Then I get a friendly message', :unit do
          [['ZNY', 'New York'],
           %w[CZY Toronto]].each do |artcc_pair|
            allow(FAAOISAPI::ARTCC).to receive(:fetch_info)
              .with('ZNY')
              .and_return(center: artcc_pair.first,
                          friendly: artcc_pair.last,
                          first_tier: nil,
                          second_tier: nil)
          end
          ewr_ground_stop[:areas_affected] =
            ewr_ground_stop[:areas_affected].reject do |item|
              item.downcase == 'all'
            end
          ewr_ground_stop[:areas_affected] << 'ZNY'
          expected_friendly_message = <<~FRIENDLY_MESSAGE.chomp
            Newark-Liberty International (EWR) is currently experiencing a \
            ground stop that's expected to end at 03:59 UTC. \
            Other airports nearby are also impacted by this, including:

            - Montreal-Trudeau International, and
            - All airports in the New York area.

            Expect delays.
          FRIENDLY_MESSAGE
          expect(FAAOISAPI::FriendlyMessage.generate(type: :program,
                                                     data: ewr_ground_stop))
            .to eq expected_friendly_message
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
