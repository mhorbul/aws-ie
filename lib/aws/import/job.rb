require 'net/http'
require 'net/https'
require 'cgi'

module Net
  class HTTP
    class AWSSignedPost < Post
      include OpenSSL

      def sign(url, aws_secret_key, sep = "\n")
        return if self.body.empty?
        self.body << "&SignatureMethod=HmacSHA1&SignatureVersion=2"
        digest = Digest::Digest.new('sha1')
        hmac = HMAC.digest(digest, aws_secret_key, canonical_string(url, sep))
        signature = CGI.escape([hmac].pack("m").strip)
        self.body << "&Signature=#{signature}"
      end

      private
      def canonical_string(url, sep)
        host = url.respond_to?(:host) ? url.host : url
        [METHOD, host, canonical_query].join(sep)
      end

      def canonical_query
        sep = '&'
        equal = '='
        self.body.split(sep).
          map { |param| param.split(equal) }.
          sort { |a,b| a[0] <=> b[0] }.
          reduce([]) { |r, p| r << p.join(equal) }.join(sep)
      end
    end
  end
end

module AWS
  module Import

    API_URL = "https://importexport.awsamazon.com"

    class Config
      class << self
        attr_accessor :aws_access_key_id
        attr_accessor :aws_secret_key_id
      end
    end

    class Job

      attr_reader :id, :manifest

      def create(manifest)
        url = URI.parse(API_URL)
        req = Net::HTTP::AWSSignedPost.new(url.path)
        req.set_form_data({ })
        req.sign(url.host, Config.aws_secret_key_id)
        Net::HTTP.new(url.host, url.port).
          start { |http| http.request(req) }
      end

    end
  end
end
