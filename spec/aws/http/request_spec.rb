require File.dirname(__FILE__) + '/../../spec_helper'
require 'aws/http/request'

describe AWS::HTTP::Request do

  let(:params) do
    { "a" => 1, "c" => 3, "d" => 4, "b" => 2, "Y" => 10 }
  end

  let(:canonical_string) do
    ["POST", "importexport.awsamazon.com", canonical_query].join("\n")
  end

  let(:query_string) do
    "a=1&b=2&Y=10&c=3&d=4"
  end

  let(:canonical_query) do
    "SignatureMethod=HmacSHA1&SignatureVersion=2&" <<
      "Timestamp=#{CGI.escape(timestamp.iso8601)}&" <<
      "Y=10&a=1&b=2&c=3&d=4"
  end

  let(:signed_query_string) do
    canonical_query + "&Signature=#{signature}"
  end

  let(:signature) do
    digest = OpenSSL::Digest::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, secret_key, canonical_string)
    CGI.escape([hmac].pack("m").strip)
  end

  let(:api_url) { "https://importexport.awsamazon.com/" }
  let(:secret_key) { "ABCDE12345" }

  context "signed request" do

    let(:timestamp) { Time.now }

    before do
      timestamp
      Time.should_receive(:now).and_return(timestamp)
    end

    it "should modify the query by adding Signature* params" do
      url = URI.parse(api_url)
      request = described_class.new("/")
      request.set_form_data(params)
      request.body.should == query_string
      request.sign(url, secret_key)
      request.body.should == signed_query_string
    end

  end

end
