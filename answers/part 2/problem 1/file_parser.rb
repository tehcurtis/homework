require 'json'

class FileParser
  def self.run(data)
    new(data).parse
  end

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def parse
    collected_info = []
    data.split("\n").each do |line|
      price = line.match(/\d+\.\d{2}$/).to_s
      date_range = line.match(/(\d{2}\/\d{2}\s\W\s\d{2}\/\d{2})/).to_s
      feature = line.match(/\$\d+\.\d+\s(.*)\d{2}\/\d{2}\s\W/)[1].strip
      hash = {
        feature: feature,
        date_range: date_range,
        price: price
      }
      print JSON.pretty_generate hash
      print "\n"
      collected_info << {price: price, date_range: date_range, feature: feature}
    end

    collected_info
  end
end
