require 'cgi'
require 'net/http'
require 'net/https'

module AWS
  class IE
    class Client
      include OpenSSL

      API_URL = "https://importexport.amazonaws.com"

      def initialize(access_key, secret_key)
        @url = URI.parse(API_URL)
        @url.path = "/" if @url.path.empty?
        @access_key = access_key
        @secret_key = secret_key
      end

      def post(params)
        request = prepare_request_with_params(params)
      end

      private
      def prepare_request_with_params(params)
        request = Net::HTTP::Post.new(@url.path)
        request.body = signed_query_string(params)
        request.content_type = "application/x-www-form-urlencoded"
        http = Net::HTTP.new(@url.host, @url.port)
        http.use_ssl = true
        http.start { |http| http.request(request) }.body
      end

      def signed_query_string(params)
        canonical_query = canonical_query_string(params)
        canonical_string = ["POST", @url.host, "/", canonical_query].join("\n")
        digest = Digest::Digest.new('sha1')
        hmac = HMAC.digest(digest, @secret_key, canonical_string)
        signature = [hmac].pack("m").strip
        canonical_query + "&Signature=" + CGI.escape(signature)
      end

      def canonical_query_string(params)
        default_params = {
          "Timestamp" => Time.now.iso8601,
          "AWSAccessKeyId" => @access_key,
          "SignatureVersion" => 2,
          "SignatureMethod" => "HmacSHA1"
        }
        params.merge!(default_params)
        sep = "&"
        params.sort { |a,b| a[0] <=> b[0] }.
          reduce([]) { |r, p| r << "#{CGI.escape(p[0].to_s)}=#{CGI.escape(p[1].to_s)}" }.
          join(sep)
      end
    end
  end
end
