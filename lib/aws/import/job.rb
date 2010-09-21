require 'rubygems'
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

      attr_reader :id, :signature
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
        params = {
          "Operation" => "CreateJob",
          "JobType" => "Import",
          "Manifest" => self.manifest,
          "ValidateOnly" => true
        }
        client = AWS::IE::Client.new(AWS::Import::Config.aws_access_key_id,
                                     AWS::Import::Config.aws_secret_key_id)
        response = client.post(params)
        xml = Nokogiri::XML(response)
        options = { "ns" => "http://importexport.amazonaws.com/doc/2010-06-01/" }
        @id = xml.root.xpath("//ns:JobId", options).text
        @signature = xml.root.xpath("//ns:Signature", options).text
      end

    end
  end
end
