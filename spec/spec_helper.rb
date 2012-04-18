# for test coverage
require 'simplecov'
require 'simplecov-rcov'
class SimpleCov::Formatter::MergedFormatter
  def format(result)
     SimpleCov::Formatter::HTMLFormatter.new.format(result)
     SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/config/"
end

require 'solrj_wrapper/settings'

$LOAD_PATH.unshift(File.dirname(__FILE__))

RSpec.configure do |config|
  # Set up the environment for testing and make all variables available to the specs
  settings_env = ENV["SETTINGS"] ||= 'dev'
  @@settings = Settings.new(settings_env)
end
