dir = File.expand_path('../../answers/part 2/problem 1/', __FILE__)
dir2 = File.expand_path('../../answers/part 2/problem 2/', __FILE__)
[dir, dir2].each do |d|
  $LOAD_PATH.unshift(d) unless $LOAD_PATH.include?(d)
end
require 'file_parser'
require 'organizations'

RSpec.configure do |config|
  config.order = :random
end
