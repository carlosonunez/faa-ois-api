# frozen_string_literal: true

require 'yaml'

module FAAOISAPI
  module FriendlyMessage
    class Loader
      @messages_template = nil

      def initialize
        @messages_template_path = 'include/friendly_messages.yml.erb'
        raise IOError, "Template not found at: #{@messages_template_path}" \
          unless template_exists?

        @messages_template ||= File.read(@messages_template_path)
      end

      def render(template_vars)
        template_context = binding

        template_vars.each do |key, val|
          template_context.local_variable_set(key, val)
        end
        begin
          YAML.safe_load(ERB.new(@messages_template).result(template_context),
                         symbolize_names: true)
        rescue StandardError => e
          raise IOError, "Failed to render template: #{e}"
        end
      end

      private

      def template_exists?
        File.exist? @messages_template_path
      end
    end
  end
end
