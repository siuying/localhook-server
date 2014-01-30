require_relative './endpoint'

module Localhook
  class EndpointService
    attr_reader :endpoints

    def initialize(endpoints=Settings.endpoints)
      @endpoints = endpoints.collect do |endpoint|
        Endpoint.parse(endpoint)
      end
    end

    def endpoint_with_token(token)
      return @endpoints.find {|e| e.accept?(token) }
    end

    def endpoint_with_name(name)
      return @endpoints.find {|e| e.name == name }
    end
  end
end