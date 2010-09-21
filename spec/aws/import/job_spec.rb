require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/ie'
require 'yaml'

describe AWS::Import::Job do

  let(:client) do
    AWS::IE::Client.new
  end

  let(:response) do
    File.read(File.join(
                        File.dirname(__FILE__),
                        "../../fixtures/#{response_file_name}"))
  end

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

  describe "when is being canceled" do

    let(:params) do
      {
        "JobType" => "Import",
        "Operation" => "CancelJob",
        "JobId" => "ABC-123"
      }
    end

    context "successfully" do

      let(:response_file_name) { "cancel_job_response_successfull.xml" }

      it "should send cancel request and get successfull response" do
        client
        AWS::IE::Client.should_receive(:new).and_return(client)
        client.should_receive(:post).with(params).and_return(response)
        described_class.cancel("ABC-123").should be_true
      end

    end

    context "failed" do

      let(:response_file_name) { "cancel_job_response_failed.xml" }

      it "should send cancel request and get failed response" do
        client
        AWS::IE::Client.should_receive(:new).and_return(client)
        client.should_receive(:post).with(params).and_return(response)
        described_class.cancel("ABC-123").should be_false
      end

    end

  end

  describe "when is being created" do

    let(:response_file_name) { "create_job_response.xml" }

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
