version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'aws-ie'
  s.version     = version
  s.summary     = 'AWS Import/Export API supoprt.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.author            = 'Maksim Horbul'
  s.email             = 'max@gorbul.net'
  s.homepage          = 'http://www.gorbul.net'

  s.add_dependency('bundler',        '~> 1.0.0')
end
