$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

# set the TZ env var to avoid Timezone conflicts when running the specs
ENV["TZ"] = "UTC"

require 'rubygems'
require 'bundler'
Bundler.setup
