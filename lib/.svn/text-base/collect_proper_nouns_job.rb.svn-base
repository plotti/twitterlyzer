class CollectProperNouns < Struct.new(:text)
  require 'net/http'
  require 'uri'
  require 'rexml/document'

  #insert API key 
  ApiKey = "s2jhybpryqrr2dzhmu7d8r9jz5e5gmjw"
  
  ApiPort = 8180
  ApiHost = 'portaltnx.openamplify.com'
  ApiPath = '/AmplifyWeb/AmplifyThis'
    
  def perform    
    URI.extract(text).each do |entry| text = text.sub(entry, "") end
    http = Net::HTTP.new(ApiHost, ApiPort)
    response = http.post(ApiPath, "apiKey=#{ApiKey}&#{input_type}=#{URI::escape(text)}")
    doc= REXML::Document.new(response.read_body)
    proper_nouns = doc.each_element('//ProperNouns//Topic//Name//text()')  
  end
  
end