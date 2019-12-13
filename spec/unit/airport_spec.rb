# frozen_string_literal: true

require 'spec_helper'

describe 'Given an airport' do
  let(:airport) { FAAOISAPI::Airport.new('DFW') }

  before(:each) { TestMocks.generate! }

  context 'When I get its IATA code' do
    example 'Then I get it', :unit do
      expect(airport.iata).to eq 'DFW'
    end
  end
  context 'When I get its full name' do
    example 'Then I get it', :unit do
      expect(airport.full_name).to eq 'Dallas-Fort Worth International'
    end
  end
end
