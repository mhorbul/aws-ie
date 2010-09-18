require 'aws/http/request'
require 'time'

module AWS
  module Import

    API_URL = "https://importexport.amazonaws.com/"

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
          "Manifest" => manifest,
          "Timestamp" => Time.now.iso8601
        }
        http = Net::HTTP.new(url.host, url.port)
        http.set_debug_output(STDOUT)
        http.use_ssl = true
        req = HTTP::Request.new(url.path)
        req.set_form_data(params)
        req.sign(url.host, Config.aws_secret_key_id)
        http.start { |http| http.request(req) }
      end

    end
  end
end
