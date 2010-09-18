require 'aws/http/request'

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
        params = {
          "Operation" => "CreateJob",
          "JobType" => "Import",
          "AWSAccessKeyId" => Config.aws_access_key_id,
          "Manifest" => manifest
        }
        req = HTTP::Request.new(url.path)
        req.set_form_data(params)
        req.sign(url.host, Config.aws_secret_key_id)
        Net::HTTP.new(url.host, url.port).
          start { |http| http.request(req) }
      end

    end
  end
end
