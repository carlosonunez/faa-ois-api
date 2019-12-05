require 'spec_helper'

describe "Given the FAA OIS page" do
  context "When I fetch it" do
    example "It condenses the page into a really nice YAML file", :unit do
      expected_output = YAML.load(File.read('spec/fixtures/example_parsed_ois_info.yml'))
      actual_output = FAAOISAPI::Page.parse
      [ :programs, :ground_stops, :delays, :closures ].each do |section|
        expect(actual_output[section]).to eq expected_output[section]
      end
    end
  end
end
