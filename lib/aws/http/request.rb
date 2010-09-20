require 'net/http'
require 'net/https'
require 'cgi'

module AWS
  module HTTP
    class Request < Net::HTTP::Post
      include OpenSSL

      def sign(url, aws_secret_key, sep = "\n")
        return if self.body.empty?
        digest = Digest::Digest.new('sha1')
        hmac = HMAC.digest(digest, aws_secret_key, canonical_string(url, sep))
        signature = [hmac].pack("m").strip
        self.body << "&Signature=#{CGI.escape(signature)}"
      end

      private
      def canonical_string(url, sep)
        host = url.respond_to?(:host) ? url.host : url
        [METHOD, host, canonical_query].join(sep)
      end

      def canonical_query
        sep = '&'
        equal = '='
        pairs = self.body.split("&")
        pairs << "SignatureMethod=HmacSHA1"
        pairs << "SignatureVersion=2"
        pairs << "Timestamp=#{CGI.escape(Time.now.iso8601)}"
        self.body = pairs.map { |pair| pair.split(equal) }.
          sort { |a,b| a[0] <=> b[0] }.
          reduce([]) { |r, p| r << p.join(equal) }.join(sep)
      end

    end
  end
end
