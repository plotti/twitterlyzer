# Print the top ten things that the document author cares
# about. Accepts a filename, a URL, or literal text.

require 'net/http'
require 'uri'
require 'rexml/document'


#insert API key here
ApiKey= "s2jhybpryqrr2dzhmu7d8r9jz5e5gmjw"

ApiPort= 8180
ApiHost= 'portaltnx20.openamplify.com'
ApiPath= '/AmplifyWeb_v20/AmplifyThis'

if ARGV.length != 1
  puts "usage: ruby-amplify.rb text|file"
  exit
end

if File.file?(ARGV[0])
  input_type= 'inputText'
  text= IO.read(ARGV[0])  ||  ARGV[0]
elsif ARGV[0] =~ /^http:/
  input_type= 'sourceURL'
  text= ARGV[0]
else
  input_type= 'inputText'
  text= ARGV[0]
end

URI.extract(text).each do |entry| text = text.sub(entry, "") end

http = Net::HTTP.new(ApiHost,ApiPort)
response = http.post(ApiPath, "apiKey=#{ApiKey}&#{input_type}=#{URI::escape(text)}")
doc= REXML::Document.new(response.read_body)
 
important_topics= REXML::XPath.match(doc, "//TopicResult").select do |topic|
  REXML::XPath.match(topic, "Polarity/Mean/Name/text()") != 'Neutral'
end

proper_nouns = doc.each_element('//ProperNouns//Topic//Name//text()')

important_topics.sort! do |a, b|
  a_importance= Float(REXML::XPath.match(a, "Polarity/Mean/Value/text()")[0].to_s).abs
  b_importance= Float(REXML::XPath.match(b, "Polarity/Mean/Value/text()")[0].to_s).abs
  a_importance <=> b_importance
end

important_topics[-10..-1].each do |topic|
  name= REXML::XPath.match(topic, "Topic/Name/text()")
  polarity= REXML::XPath.match(topic, "Polarity/Mean/Name/text()")
  puts "#{name}: #{polarity}"
end
