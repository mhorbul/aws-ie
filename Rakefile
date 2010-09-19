require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'

Spec::Rake::SpecTask.new

spec = eval(File.read('aws-ie.gemspec'))
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

