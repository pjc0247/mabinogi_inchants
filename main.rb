require 'net/http'
require 'nokogiri'
require 'ostruct'
require 'json'

uri = "http://mabinogi.inexeed.com/enchant/?kname="
keyword = '' # 검색 키워드
xpath = '/html/body/div[1]/div[3]/div[1]/table/tr[position()>1]'

doc = Net::HTTP.get(URI(uri+URI::encode(keyword)))

html = Nokogiri::HTML(doc)

chunks = html.xpath(xpath)
inchants = Array.new

chunks.each do |chunk|
	contents = chunk.xpath('td')
    sub_contents = contents[3].children
    
    data = OpenStruct.new
    data.fix = contents[0].text
    data.rank = contents[1].text
    data.position = sub_contents[0].text
    data.name = lambda do 
      result = ""
      contents[2].children.each do |name|
        result += name.text + "|"
      end
      return result
    end.call
    data.effects = lambda do 
      result = ""
      sub_contents[1..-1].each do |effect|
      	result += effect.text + "|"
      end
      return result
    end.call

    inchants.push data.to_h
end

File.open('output.txt', 'w') do |fp|
	fp.write JSON.dump(inchants)
end
