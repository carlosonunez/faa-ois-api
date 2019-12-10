# frozen_string_literal: true

require 'spec_helper'

describe 'Given an airport' do
  context 'When I look up its center on iFlightPlanner' do
    example 'Then I get its IATA', :unit do
      allow(HTTParty).to receive(:get)
        .with($iflightplanner_url)
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read($expected_iflightplanner_html)))
      expect(FAAOISAPI::Airports.get_artcc('DFW')).to eq 'ZFW'
    end
  end
end
