# frozen_string_literal: true

require 'spec_helper'

describe 'Given an airport' do
  context 'When I get its full name' do
    example 'Then I get it', :unit do
      allow(HTTParty).to receive(:get)
        .with($iflightplanner_url)
        .and_return(double(HTTParty::Response,
                           code: 200,
                           body: File.read($expected_iflightplanner_html)))
      airport = FAAOISAPI::Airport.new('DFW')
      expect(airport.full_name).to eq 'Dallas-Fort Worth International'
    end
  end
end
