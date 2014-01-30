module Localhook
  class Endpoint
    attr_reader :name
    attr_reader :token

    def initialize(name, token)
      @name = name
      @token = token
    end

    def accept?(requets_token)
      requets_token == @token
    end

    # raise ArgumentError if the endpoint_string is not in format name:token
    def self.parse(endpoint_string)
      name, token = endpoint_string.split(":")
      if name && token
        Endpoint.new(name, token)
      else
        raise ArgumentError, "missing endpoing token: endpoint format must be '<name>:<token>'"
      end
    end
  end
end