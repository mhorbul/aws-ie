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
          success = xml.root.xpath("//Success").text
          return success == "true"
        end

        def find(job_id)
          self.new.find(job_id)
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
        @id = xml.root.xpath("//JobId").text
        @signature = xml.root.xpath("//Signature").text
      end

      def find(job_id)
        params = {
            "Operation" => "GetStatus",
          "JobId" => job_id
        }
        xml = request(params)
        @id = xml.root.xpath("//JobId").text
        @manifest = xml.root.xpath("//CurrentManifest").text
        self
      end

      private
      def request(params)
        params.merge!("JobType" => "Import")
        client = AWS::IE::Client.new
        xml = Nokogiri::XML(client.post(params))
        xml.remove_namespaces!
        xml
      end
    end
  end
end
