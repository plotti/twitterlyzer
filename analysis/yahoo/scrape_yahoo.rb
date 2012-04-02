require 'rubygems'
require 'nokogiri'
require 'open-uri'


#topdomains = ["arts", "news_and_media","business_and_economy", "recreation", "computers_and_internet", "reference", "education", "regional", "entertainment", "science", "government", "social_science", "health", "society_and_culture"]
topdomains = ["business_and_economy", "recreation", "computers_and_internet", "reference", "education", "regional", "entertainment", "science", "government", "social_science", "health", "society_and_culture"]

@seen_words = []
File.readlines("seenwords.csv").each do |line|
        @seen_words << line.sub!(/\n/,"")
end
@seen_words_file = File.open("seenwords.csv", "a+")


def write_net(father, son)
	 if @seen_words.include?(son) && !son.include?("@")
                        @file.puts "#{father} #{father}_#{son}"
         else
                        @file.puts "#{father} #{son}"
         end
         @seen_words_file.puts son
end

i = 0
topdomains.each do |domain|
	@file = File.open("#{domain}.csv", "w+")
	puts "done domain #{domain}"
	site =  Nokogiri::HTML(open("http://dir.yahoo.com/#{domain}"))
	site.css("div.cat li a").each do |link|
		first_level_link = link.content.gsub(" ","_").downcase
		write_net(domain,first_level_link)
		puts "working on #{first_level_link}"
		if first_level_link.include? "@"
			first_level_link.gsub!("@","")
			sub_site = Nokogiri::HTML(open("http://dir.yahoo.com/#{first_level_link}"))
		else
			sub_site = Nokogiri::HTML(open("http://dir.yahoo.com/#{domain}/#{first_level_link}"))
		end
		sub_site.css("div.cat li a").each do |sub_link|
			i += 1
			puts i.to_s
			second_level_link = sub_link.content.gsub(" ","_").downcase
			write_net(first_level_link, second_level_link)
			if second_level_link.include? "@"
				second_level_link.gsub!("@","")
				sub_sub_site = Nokogiri::HTML(open("http://dir.yahoo.com/#{second_level_link}"))
			else
				sub_sub_site = Nokogiri::HTML(open("http://dir.yahoo.com/#{domain}/#{first_level_link}/#{second_level_link}"))
			end
			sub_sub_site.css("div.cat li a").each do |sub_sub_link|
				third_level_link = sub_sub_link.content.gsub(" ","_").downcase
				write_net(second_level_link, third_level_link)
			end
		end
	end
end
@file.close
