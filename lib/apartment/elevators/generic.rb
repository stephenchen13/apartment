require 'rack/request'
require 'apartment/tenant'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on request
    #
    class Generic

      def initialize(app, processor = nil)
        @app = app
        @processor = processor || method(:parse_tenant_name)
      end

      def call(env)
        request = Rack::Request.new(env)

        unless Apartment.exclude_request_regex && request.path =~ Apartment.exclude_request_regex
          database = @processor.call(request)
        end

        if database
          Apartment::Tenant.switch(database) { @app.call(env) }
        else
          @app.call(env)
        end
      end

      def parse_tenant_name(request)
        raise "Override"
      end
    end
  end
end
