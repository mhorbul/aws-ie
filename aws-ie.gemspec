version = File.read(File.expand_path("../VERSION",__FILE__)).strip
require 'bundler'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'aws-ie'
  s.version     = version
  s.summary     = 'AWS Import/Export API supoprt.'
  s.homepage    = "http://rubygems.org/gems/aws-ie"

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">=1.3.0"
  s.add_dependency "nokogiri", ">=1.4.3.1"

  s.author            = 'Maksim Horbul'
  s.email             = 'max@gorbul.net'

  s.files = [
    "README.org",
    "COPYING",
    "Gemfile",
    "Rakefile",
    "VERSION",
    "aws-ie.gemspec",
    "lib/aws/ie.rb",
    "lib/aws/import/job.rb",
    "lib/aws/ie/client.rb",
    "spec/aws/import/job_spec.rb",
    "spec/aws/ie/client_spec.rb"
   ]
   s.require_path = 'lib'
end
