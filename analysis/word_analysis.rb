require 'rubygems'
require 'wordnet'
require 'nokogiri'
require 'cgi'
require 'open-uri'

#words = ["yoga", "youtube", "etsy", "poker", "dance", "cinema", "poetry", "history", "outdoors", "gardening", "rapper", "handmade", "anime", "php", "college", "publishing", "linux", "restaurant", "baseball", "guitar", "theatre", "beer", "musician", "tech", "marketing", "sport", "fashion", "photography", "politics", "news", "gaming", "comedy", "food", "advertising", "realestate", "football"]
words = []
File.readlines("groups.txt").each do |line|
	words << line.sub!(/\n/,"")
end
index = WordNet::NounIndex.instance
file = File.open("output.csv", "w+")
words.each do |word|
	puts "Working on word: #{word}"
	wordnet = index.find(word)
	if wordnet != nil
		puts "#{wordnet.synsets.count} Synsets found for #{word}"
		max = 0
		best_synset = ""
		wordnet.synsets.each do |synset|
			searchterm = "#{word} #{synset.gloss}".map { |w| CGI.escape(w) }.join("+")
			site =  Nokogiri::HTML(open("http://www.google.ch/search?q=#{searchterm}"))
			r = site.css("#subform_ctrl div").children.last.content.to_s
			r.gsub!("'","")
			results = r.gsub(/[^0-9]/,"").to_i
			puts "Found #{results} for gloss #{synset.gloss}"
			if results > max
				max = results
				best_synset = synset
			end
		end
		
		last_word = word
		next_word = best_synset.hypernym
		while next_word != nil && next_word.words.first != last_word
			file.puts "#{last_word};#{next_word.words.first} \n"
			#puts "#{last_word} H: #{next_word.words.join(" ")}"
			last_word = next_word.words.first
			next_word = next_word.hypernym
		end
	else
		puts "Nothing found for #{word}"
	end
end
file.close
