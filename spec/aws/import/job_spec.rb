require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/import/job'

describe Net::HTTP::AWSSignedPost do

  let(:params) do
    { "a" => 1, "c" => 3, "d" => 4, "b" => 2, "Y" => 10 }
  end

  let(:canonical_string) do
    ["POST",
     "importexport.awsamazon.com",
     "SignatureMethod=HmacSHA1&SignatureVersion=2&Y=10&a=1&b=2&c=3&d=4"].
      join("\n")
  end

  let(:query_string) do
    "a=1&b=2&Y=10&c=3&d=4" <<
      "&SignatureMethod=HmacSHA1&SignatureVersion=2&" <<
      "Signature=#{signature}"
  end

  let(:signature) do
    digest = OpenSSL::Digest::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, secret_key, canonical_string)
    CGI.escape([hmac].pack("m").strip)
  end

  let(:api_url) { "https://importexport.awsamazon.com/" }
  let(:secret_key) { "ABCDE12345" }

  it "should be able to sign the request" do
    url = URI.parse(api_url)
    request = described_class.new("/")
    request.set_form_data(params)
    request.sign(url, secret_key)
    request.body.should == query_string
  end

end

describe AWS::Import::Job do

  describe "when is being created" do

    let(:url_path) { "/" }
    let(:url_host) { "importexport.awsamazon.com" }
    let(:url_port) { 443 }

    let(:request) do
      Net::HTTP::AWSSignedPost.new(url_path)
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

    before do
      request
      Net::HTTP::AWSSignedPost.stub!(:new).and_return(request)
      Net::HTTP.stub!(:new).with(url_host, url_port).and_return(http)
      AWS::Import::Config.aws_access_key_id = access_key
      AWS::Import::Config.aws_secret_key_id = secret_key
    end

    it "should prepare the API request" do
      Net::HTTP::AWSSignedPost.should_receive(:new).and_return(request)
      request.should_receive(:set_form_data).with({ })
      request.should_receive(:sign).with(url_host, secret_key)
      job = described_class.new
      job.create(manifest)
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
