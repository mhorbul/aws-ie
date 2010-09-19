require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/import/job'
require 'yaml'

describe AWS::Import::Job do

  describe "in general" do

    it "should have manifest" do
      job = described_class.new
      job.manifest.should be_nil
      job.manifest = "manifest content"
      job.manifest.should == "manifest content"
    end

    it "should get the parameters from constructor" do
      job = described_class.new(:manifest => "manifest content")
      job.manifest.should == "manifest content"
    end

  end

  describe "when is being created" do

    let(:url_path) { "/" }
    let(:url_host) { "importexport.amazonaws.com" }
    let(:url_port) { 443 }

    let(:request) do
      AWS::HTTP::Request.new(url_path)
    end

    let(:response) do
      response_file = File.
        join(File.dirname(__FILE__), "../../fixtures/create_job_response.xml")
      File.read(response_file)
    end

    let(:http) do
      stubs = {
        :start => response,
        :use_ssl= => nil,
        :request => response,
        :set_debug_output => nil
      }
      mock("Net::HTTP", stubs)
    end

    let(:manifest) do
      { }
    end

    let(:access_key) { "AccessKey12345ABCDE" }
    let(:secret_key) { "SecretKey12345ABCDE" }

    let(:timestamp) { Time.now }

    let(:params) do
      { "JobType" => "Import", "Operation" => "CreateJob",
        "AWSAccessKeyId" => access_key,
        "Manifest" => manifest.to_yaml,
        "Timestamp" => timestamp.iso8601 }
    end

    before do
      request
      timestamp
      Time.should_receive(:now).and_return(timestamp)
      AWS::HTTP::Request.stub!(:new).and_return(request)
      Net::HTTP.stub!(:new).with(url_host, url_port).and_return(http)
      AWS::Import::Config.aws_access_key_id = access_key
      AWS::Import::Config.aws_secret_key_id = secret_key
    end

    it "should prepare the API request" do
      AWS::HTTP::Request.should_receive(:new).and_return(request)
      request.should_receive(:set_form_data).with(params)
      request.should_receive(:sign).with(url_host, secret_key)
      described_class.create(:manifest => manifest.to_yaml).
        should be_instance_of(described_class)
    end

    it "should send API request" do
      Net::HTTP.should_receive(:new).with(url_host, url_port).and_return(http)
      http.should_receive(:use_ssl=).with(true)
      http.should_receive(:start).and_yield(http)
      http.should_receive(:request).with(request).and_return(response)
      described_class.create(:manifest => manifest.to_yaml).
        should be_instance_of(described_class)
    end

    it "should get the Job ID from response" do
      job = described_class.create(:manifest => manifest.to_yaml)
      job.id.should == "ABC-123"
    end

    describe "and error occures" do

      it "should have the error code and description"
      it "should not get the Job ID"

    end

  end

end
