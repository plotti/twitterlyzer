require 'rubygems'
require 'nokogiri'
require 'open-uri'


@file = File.open("yahoo.csv", "w+")

topdomains = ["arts", "news_and_media","business_and_economy", "recreation", "computers_and_internet", "reference", "education", "regional", "entertainment", "science", "government", "social_science", "health", "society_and_culture"]

seen_words = []
topdomains.each do |domain|

	site =  Nokogiri::HTML(open("http://dir.yahoo.com/#{domain}"))
	site.css("div.cat li a").each do |link|
		short_link = link.content.gsub(" ","_").downcase
		if seen_words.include?(short_link) and !short_link.include?("@")
    		  	@file.puts "#{domain} #{domain}_#{short_link}"
		else
			@file.puts "#{domain} #{short_link}"
		end
		seen_words << short_link
		sub_site = Nokogiri::HTML(open("http://dir.yahoo.com/#{domain}/#{short_link}"))
		sub_site.css("div.cat li a").each do |sub_link|
			sub_short_link = sub_link.content.gsub(" ","_").downcase
			if seen_words.include? sub_short_link and !sub_short_link.include? "@"
                	        @file.puts "#{short_link} #{short_link}_#{sub_short_link}"
	                else
        	                @file.puts "#{short_link} #{sub_short_link}"
                	end
			seen_words << sub_short_link
		end
	end
end
@file.close

