require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/ie/client'

describe AWS::IE::Client do

  let(:manifest) do
    { }
  end

  let(:params) do
    {
      "Operation" => "CreateJob",
      "JobType" => "Import",
      "Manifest" => manifest.to_yaml
    }
  end

  let(:signed_query_string) do
    "AWSAccessKeyId=ABC-123" +
      "&JobType=Import" +
      "&Manifest=---+%7B%7D%0A%0A" +
      "&Operation=CreateJob" +
      "&SignatureMethod=HmacSHA1" +
      "&SignatureVersion=2" +
      "&Timestamp=#{CGI.escape(timestamp.iso8601)}" +
      "&Signature=TmrawVUfcCTcR%2FLYdWyOWeQsgaA%3D"
  end

  let(:timestamp) { Time.parse("2010-09-20 05:10:35") }

  let(:post_request) { Net::HTTP::Post.new("/") }

  let(:http) do
    stubs = {
      :start => response,
      :use_ssl= => nil,
      :request => response,
      :set_debug_output => nil
    }
    mock("Net::HTTP", stubs)
  end

  let(:response) do
    mock("Response", :body => "<xml />")
  end

  let(:host) { "importexport.amazonaws.com" }
  let(:port) { 443 }

  let(:access_key) { "ABC-123" }
  let(:secret_key) { "123-ABC" }

  before do
    post_request
    timestamp
    Time.should_receive(:now).and_return(timestamp)
  end

  it "should prepare HTTP Post signed request" do
    Net::HTTP.stub!(:new).and_return(http)
    Net::HTTP::Post.should_receive(:new).with("/").and_return(post_request)
    post_request.should_receive(:body=).with(signed_query_string)
    post_request.should_receive(:content_type=).
      with("application/x-www-form-urlencoded")
    client = described_class.new(access_key, secret_key)
    client.post(params)
  end

  it "should send the signed request" do
    Net::HTTP::Post.stub!(:new).and_return(post_request)
    Net::HTTP.should_receive(:new).with(host, port).and_return(http)
    http.should_receive(:start).and_yield(http)
    http.should_receive(:use_ssl=).with(true)
    http.should_receive(:request).with(post_request).and_return(response)
    client = described_class.new(access_key, secret_key)
    client.post(params).should == "<xml />"
  end

end

