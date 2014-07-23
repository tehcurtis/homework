lib = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'file_parser'

RSpec.configure do |config|
  config.order = :random
end
