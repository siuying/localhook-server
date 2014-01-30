require "rubygems"
require "bundler"
Bundler.require :default, :test, :development
require 'json'

require_relative '../app/actions/post_action'

describe PostAction do
  subject { PostAction.new(double(:request).as_null_object) }

  context "-channel_with_path" do
    it "use first section of path to build channel" do
      path = subject.channel_with_path("/myendpoint/webhook")
      expect(path).to eq("webhook.myendpoint")
    end

    it "work when no path supplied" do
      path = subject.channel_with_path("/myendpoint/")
      expect(path).to eq("webhook.myendpoint")

      path = subject.channel_with_path("/myendpoint")
      expect(path).to eq("webhook.myendpoint")
    end
  end

  context "-forwarded_data" do
    it "construct data to forward by request path, env, query_string and body" do 
      request = double(:request)
      request.stub(:path).and_return("/myendpoint/webhook")
      request.stub(:env).and_return([])
      request.stub(:query_string).and_return("")
      request.stub(:body).and_return(double(:body, :string => "{}"))

      data = subject.forwarded_data(request.as_null_object)
      expect(data[:action]).to eq("post")
      expect(data[:path]).to eq("/webhook")
      expect(data[:query_string]).to eq("")
      expect(data[:body]).to eq("{}")
      expect(data[:headers]).to eq([])
    end
  end

  context "-start" do
    let(:request) {
      request = double(:request)
      request.stub(:path).and_return("/myendpoint/webhook")
      request.stub(:env).and_return([])
      request.stub(:query_string).and_return("")
      request.stub(:body).and_return(double(:body, :string => "{}"))
      request
    }

    it "publish the data to endpoint specified by the path" do 
      subject.stub(:request).and_return(request)
      expect(subject).to receive(:publish_data).with("webhook.myendpoint", anything)
      subject.start
    end

    it "publish the JSON encoded data" do 
      data = subject.forwarded_data(request.as_null_object)
      json = data.to_json

      subject.stub(:request).and_return(request)
      expect(subject).to receive(:publish_data).with(anything, json)
      subject.start
    end
  end
end