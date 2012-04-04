require 'rubygems'
require 'wordnet'
require 'nokogiri'
require 'cgi'
require 'open-uri'
@toplevel = ["politics", "technology", "recreation", "medium", "entertainment", "education", "fashion", "business", "travel", "health"]
words = []
File.readlines("groups.txt").each do |line|
	words << line.sub!(/\n/,"")
end
words += @toplevel


@index = WordNet::NounIndex.instance
@file = File.open("wordnet.csv", "w+")
@log = File.new("wordnet.log", "w+")

def get_tree(word, synset, get_height = false)
		last_word = word
                next_word = synset.hypernym
		height = 0
                while next_word != nil && next_word.words.first != last_word
                        if get_height == true
				height += 1
			else
				@file.puts "#{last_word};#{next_word.words.first} \n"
			end
                        last_word = next_word.words.first
                        next_word = next_word.hypernym
                end
		puts "Height #{height}"
		return height
end

def get_best_synset(word,synsets)
	best_synset = ""
	if @toplevel.include? word #Look for synset with lowest hight to root
		min = 100
		@position = @index.find(word)
		@position.synsets.each do |synset|
	                height = get_tree(word,synset,true)
        	        if height != 0 && height < min
                	        min = height
                        	best_synset = synset
	                end
		end
	else #Look for synset with highest amount of google hits
		max = 0
                synsets.each do |synset|
			short_gloss = synset.gloss.split[0..(15)].join(" ") #cut gloss down to 10 words for better comparability
                        searchterm = "#{word} #{short_gloss}".map { |w| CGI.escape(w) }.join("+")
                        site =  Nokogiri::HTML(open("http://www.google.ch/search?q=#{searchterm}"))
                        r = site.css("#subform_ctrl div").children.last.content.to_s
                        r.gsub!("'","")
                        results = r.gsub(/[^0-9]/,"").to_i
                        @log.puts "Found #{results} for gloss #{short_gloss}"
                        if results > max
                                max = results
                                best_synset = synset
                        end
                end	
	end
	return best_synset
end

words.each do |word|
	puts "Working on word: #{word}"
	@position = @index.find(word)
	if @position != nil
		puts "#{@position.synsets.count} Synsets found for #{word}"
		max = 0
		best_synset = get_best_synset(word, @position.synsets)
		get_tree(word,best_synset)
	else
		puts "Nothing found for #{word}"
	end
end
@file.close
@log.close
