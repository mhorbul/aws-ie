require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/ie'
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

    let(:response) do
      response_file = File.
        join(File.dirname(__FILE__), "../../fixtures/create_job_response.xml")
      File.read(response_file)
    end

    let(:manifest) do
      { }
    end

    let(:params) do
      {
        "JobType" => "Import",
        "Operation" => "CreateJob",
        "Manifest" => manifest.to_yaml
      }
    end

    before do
      client
      AWS::IE::Client.stub!(:new).and_return(client)
      client.stub!(:post).and_return(response)
    end

    let(:client) do
      AWS::IE::Client.new
    end

    it "should create AWS::IE::Client instance" do
      AWS::IE::Client.should_receive(:new).and_return(client)
      described_class.create(:manifest => manifest.to_yaml).
        should be_instance_of(described_class)
    end

    it "should send API request" do
      client.should_receive(:post).with(params).and_return(response)
      described_class.create(:manifest => manifest.to_yaml).
        should be_instance_of(described_class)
    end

    it "should get the Job ID from response" do
      job = described_class.create(:manifest => manifest.to_yaml)
      job.id.should == "45HFS-VALIDATE-ONLY"
    end

    it "should have the signature" do
      job = described_class.create(:manifest => manifest.to_yaml)
      job.signature.should == "/dxgK27c8++SFiZLLaIvHt4Oy4k="
    end

    describe "and error occures" do

      it "should have the error code and description"
      it "should not get the Job ID"

    end

  end

end
