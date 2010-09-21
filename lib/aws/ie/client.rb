require 'net/http'
require 'net/https'
require 'time'

module AWS
  class IE
    class Client

      API_URL = "https://importexport.amazonaws.com"

      class << self
        attr_accessor :aws_access_key_id
        attr_accessor :aws_secret_key_id
        attr_accessor :test_mode
      end

      def initialize
        @url = URI.parse(API_URL)
        @url.path = "/" if @url.path.empty?
      end

      def post(params)
        request = prepare_request_with_params(params)
        http = Net::HTTP.new(@url.host, @url.port)
        http.set_debug_output STDOUT
        http.use_ssl = true
        http.start { |http| http.request(request) }.body
      end

      private
      def prepare_request_with_params(params)
        request = Net::HTTP::Post.new(@url.path)
        request.body = signed_query_string(params)
        request.content_type = "application/x-www-form-urlencoded"
        request
      end

      def signed_query_string(params)
        canonical_query = canonical_query_string(params)
        canonical_string = ["POST", @url.host, "/", canonical_query].join("\n")
        digest = OpenSSL::Digest::Digest.new('sha1')
        hmac = OpenSSL::HMAC.
          digest(digest, self.class.aws_secret_key_id, canonical_string)
        signature = [hmac].pack("m").strip
        canonical_query + "&Signature=" + urlencode(signature)
      end

      def canonical_query_string(params)
        default_params = {
          "Timestamp" => Time.now.iso8601,
          "AWSAccessKeyId" => self.class.aws_access_key_id,
          "SignatureVersion" => 2,
          "SignatureMethod" => "HmacSHA1"
        }
        default_params["ValidateOnly"] = true if self.class.test_mode == true
        params.merge!(default_params)
        sep = "&"
        params.sort { |a,b| a[0] <=> b[0] }.
          reduce([]) { |r, p| r << "#{urlencode(p[0].to_s)}=#{urlencode(p[1].to_s)}" }.
          join(sep)
      end

      def urlencode(str)
        r = /[^-_.!~*'()a-zA-Z\d;\/?@&$,\[\]]/n
        URI.escape(str, r)
      end
    end
  end
end
