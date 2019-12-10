# frozen_string_literal: true

module FAAOISAPI
  module Helpers
    module HTML
      def self.create_xpath_query(header_title)
        xpath_query =
          "/html/body/center/table[contains(.,'#{header_title.upcase}')]/tr"
        # OMG I HATE THE INTERNET.
        # "Delay Info" and "Airport Closures" are two cells
        # AS TWO SEPARATE TABLE BODIES
        # ON THE SAME FUCKING ROW
        special_tables = ['DELAY INFO', 'AIRPORT CLOSURES']
        if special_tables.include? header_title
          position = special_tables.find_index(header_title) + 1
          xpath_query += "/td[#{position}]/table/tr"
        end
        xpath_query
      end
    end
  end
end
