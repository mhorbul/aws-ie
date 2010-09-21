require 'rubygems'
require 'nokogiri'

module AWS
  module Import

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
          "Manifest" => self.manifest
        }
        client = AWS::IE::Client.new
        response = client.post(params)
        xml = Nokogiri::XML(response)
        options = { "ns" => "http://importexport.amazonaws.com/doc/2010-06-01/" }
        @id = xml.root.xpath("//ns:JobId", options).text
        @signature = xml.root.xpath("//ns:Signature", options).text
      end

    end
  end
end
