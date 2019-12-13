require 'spec_helper'

describe 'Given FAA OIS data' do
  context 'When a national program is in place' do
    context 'And no other areas are affected' do
      example 'Then I get a friendly message describing it', :unit do
        allow(FAAOISAPI::Airport).to receive(:new)
          .and_return(double(FAAOISAPI::Airport,
                             full_name: 'Newark-Liberty International',
                             iata: 'EWR'))
        example_output =
          YAML.safe_load(File.read('spec/fixtures/example_parsed_ois_info.yml'),
                         symbolize_names: true)
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
