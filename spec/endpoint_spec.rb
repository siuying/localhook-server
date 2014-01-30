require_relative "../app/models/endpoint"

describe Localhook::Endpoint do
  context "::parse" do
    it "accept endpoint with name and token" do
      endpoint = Localhook::Endpoint.parse("name:token")
      expect(endpoint.name).to eq("name")
      expect(endpoint.token).to eq("token")
    end
  end
end