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

        def cancel(job_id)
          params = {
            "Operation" => "CancelJob",
            "JobId" => job_id
          }
          xml = self.new.send(:request, params)
          options = { "ns" => "http://importexport.amazonaws.com/doc/2010-06-01/" }
          success = xml.root.xpath("//ns:Success", options).text
          return success == "true"
        end

      end

      def initialize(attributes = { }, &block)
        @manifest = attributes[:manifest]
        block.call(self) if block_given?
      end

      def save
        params = {
          "Operation" => "CreateJob",
          "Manifest" => self.manifest
        }
        xml = request(params)
        options = { "ns" => "http://importexport.amazonaws.com/doc/2010-06-01/" }
        @id = xml.root.xpath("//ns:JobId", options).text
        @signature = xml.root.xpath("//ns:Signature", options).text
      end

      private
      def request(params)
        params.merge!("JobType" => "Import")
        client = AWS::IE::Client.new
        Nokogiri::XML(client.post(params))
      end
    end
  end
end
