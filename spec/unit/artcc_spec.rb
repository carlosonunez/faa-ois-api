# frozen_string_literal: true

require 'spec_helper'

describe 'Given an airport' do
  context 'When I look up its center' do
    example "Then I get the center's identifier", :unit do
      allow(HTTParty).to receive(:get)
        .with($iflightplanner_url)
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read($expected_iflightplanner_html)))
      airport = FAAOISAPI::Airport.new('DFW')
      expect(airport.artcc).to eq 'ZFW'
    end
  end
end

describe 'Given a ARTCC identifier' do
  context 'When I look it up in our table' do
    example 'Then I get more information about it', :unit do
      expect(FAAOISAPI::ARTCC.fetch_info('ZFW')).to eq(
        center: 'ZFW',
        friendly: 'Fort Worth',
        first_tier: [
          { center: 'ZAB', friendly: 'Alberquerque' },
          { center: 'ZKC', friendly: 'Kansas City' },
          { center: 'ZME', friendly: 'Memphis' },
          { center: 'ZHU', friendly: 'Houston' }
        ],
        second_tier: [
          { center: 'ZLA', friendly: 'Los Angeles' },
          { center: 'ZDV', friendly: 'Denver' },
          { center: 'ZMP', friendly: 'Minneapolis' },
          { center: 'ZAU', friendly: 'Chicago' },
          { center: 'ZID', friendly: 'Indianapolis' },
          { center: 'ZTL', friendly: 'Atlanta' },
          { center: 'ZJX', friendly: 'Jacksonville' },
          { center: 'ZMA', friendly: 'Miami' }
        ]
      )
    end
  end
end
