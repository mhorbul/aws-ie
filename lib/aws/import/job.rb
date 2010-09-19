require 'aws/http/request'
require 'time'
require 'nokogiri'

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

      attr_reader :id
      attr_accessor :manifest

      class << self

        def create(attributes = { })
          self.new(attributes) do |job|
            job.save
          end
        end

      end

      def initialize(attributes = { }, &block)
        @manifest = attributes[:manifest]
        block.call(self) if block_given?
      end

      def save
        url = URI.parse(API_URL)
        params = {
          "Operation" => "CreateJob",
          "JobType" => "Import",
          "AWSAccessKeyId" => Config.aws_access_key_id,
          "Manifest" => self.manifest,
          "Timestamp" => Time.now.iso8601
          }
        http = Net::HTTP.new(url.host, url.port)
        http.set_debug_output(STDOUT)
        http.use_ssl = true
        req = HTTP::Request.new(url.path)
        req.set_form_data(params)
        req.sign(url.host, Config.aws_secret_key_id)
        response = http.start { |http| http.request(req) }
        xml = Nokogiri::XML(response)
        options = { "ns" => "http://importexport.amazonaws.com/" }
        @id = xml.root.xpath("//ns:JobId", options).text
      end

    end
  end
end
