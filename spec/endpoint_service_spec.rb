require_relative "../app/models/endpoint_service"

describe Localhook::EndpointService do
  subject { Localhook::EndpointService.new(["name:token1", "name2:token2"]) }

  context "-initialize" do
    it "create endpoints by config" do
      expect(subject.endpoints.size).to eq(2)
    end
  end

  context "-endpoint_with_token" do
    it "find endpoint with token" do
      expect(subject.endpoint_with_token("token1").name).to eq("name")
      expect(subject.endpoint_with_token("token2").name).to eq("name2")
    end

    it "return nil if not found" do
      expect(subject.endpoint_with_token("token3")).to be_nil
    end
  end

  context "-endpoint_with_name" do
    it "find endpoint with name" do
      expect(subject.endpoint_with_name("name").name).to eq("name")
      expect(subject.endpoint_with_name("name2").name).to eq("name2")
    end

    it "return nil if not found" do
      expect(subject.endpoint_with_name("name3")).to be_nil
    end
  end
end