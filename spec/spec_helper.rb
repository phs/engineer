$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
gem 'jeweler', '>= 1.4.0'

require 'engineer'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end
