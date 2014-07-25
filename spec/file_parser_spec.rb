# -*- coding: utf-8 -*-

RSpec.describe FileParser do
  describe '#load_file' do
    let(:data) { '$4.99 TXT MESSAGING - 250 09/20 - 10/28 4.99' }

    before do
      mock_stdout = double(:stdout, print: nil)
      @output = FileParser.new(data, mock_stdout).parse
    end

    it 'is able to find the price' do
      expect(@output.first[:price]).to eq '4.99'
    end

    it 'is able to find the date_range' do
      expect(@output.first[:date_range]).to eq '09/20 - 10/28'
    end

    it 'is able to find the feature' do
      expect(@output.first[:feature]).to eq 'TXT MESSAGING - 250'
    end
  end
end
