require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/import/job'
require 'yaml'

describe AWS::Import::Job do

  describe "when is being created" do

    let(:url_path) { "/" }
    let(:url_host) { "importexport.awsamazon.com" }
    let(:url_port) { 443 }

    let(:request) do
      AWS::HTTP::Request.new(url_path)
    end

    let(:response) do
      "<xml />"
    end

    let(:http) do
      stubs = {
        :start => response,
        :use_ssl= => nil,
        :request => response
      }
      mock("Net::HTTP", stubs)
    end

    let(:manifest) do
      { }
    end

    let(:access_key) { "AccessKey12345ABCDE" }
    let(:secret_key) { "SecretKey12345ABCDE" }

    let(:params) do
      { "JobType" => "Import", "Operation" => "CreateJob",
        "AWSAccessKeyId" => access_key, "Manifest" => manifest.to_yaml }
    end

    before do
      request
      AWS::HTTP::Request.stub!(:new).and_return(request)
      Net::HTTP.stub!(:new).with(url_host, url_port).and_return(http)
      AWS::Import::Config.aws_access_key_id = access_key
      AWS::Import::Config.aws_secret_key_id = secret_key
    end

    it "should prepare the API request" do
      AWS::HTTP::Request.should_receive(:new).and_return(request)
      request.should_receive(:set_form_data).with(params)
      request.should_receive(:sign).with(url_host, secret_key)
      job = described_class.new
      job.create(manifest.to_yaml)
    end

    it "should send API request" do
      Net::HTTP.should_receive(:new).with(url_host, url_port).and_return(http)
      http.should_receive(:start).and_yield(http)
      http.should_receive(:request).with(request).and_return(response)
      job = described_class.new
      job.create(manifest)
    end

    it "should get the Job ID from response"

    describe "and error occures" do

      it "should have the error code and description"
      it "should not get the Job ID"

    end

  end

end
