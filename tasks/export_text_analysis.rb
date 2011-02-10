require 'rubygems'
require 'lingua/stemmer'
require 'gnuplot'
require 'uri'
require 'csv'
require "tasks/module/AlchemyAPI.rb"
require 'rexml/document'

PARTY = {}
CSV.open("tasks/politiker_parteien.csv", "r") do |row|
	PARTY[row[0]] = row[1]
end

# Create an AlchemyAPI object.
alchemyObj = AlchemyAPI.new()
alchemyObj.loadAPIKey("api_key.txt")
MAXLENGTH= 80000

#stemmer, tagger and twitter
stemmer = Lingua::Stemmer.new(:language => "de")

#Stopwords
STOPWORDS = []
File.open("tasks/STOPWORDS_DE.txt").each_line do |line|
	STOPWORDS << line.chomp
end

#Get Persons Tweets
texts  = []
terms = {}
person_names = []
puts "Collecting Tweets"
Person.all.each do |person|
	result = person.get_all_entries.collect{|entry| entry.text + " "}.to_s
	if result != ""
		texts << result
		person_names << person.username.downcase
	end	
end

@umlauts = {
    '&amp;#252;' => 'ü',
   '&amp;#228;' => 'ä',
   '&amp;#246;' => 'ö',
   '&amp;#220;;' => 'Ü',
   '&amp;#196;' => 'Ä',
   '&amp;#214;' => 'Ö',
   '&amp;#223;' => 'ß',
  }

#go through texts and tag, stem and stopwordremove
puts "Counting words"
texts.each_with_index do |mytext,i|
	puts "Analyzing Person #{i}"
	#Remove all uris from text
	URI.extract(mytext).each do |entry|
		mytext = mytext.sub(entry, "")
	end
	proper_nouns = []
	if mytext.length > MAXLENGTH
		slices = []		
		parts = (mytext.length.to_f / MAXLENGTH).round
		partlength = (mytext.length.to_f / parts).round		
		puts "Slicing text into #{parts} parts of length #{partlength} ."
		for part in 1..parts
			if partlength > mytext.length
				partlength = mytext.length
			end
			slices << mytext.slice!(0, partlength)			
		end
		slices.each do |slice|
			begin
				endresult = alchemyObj.TextGetRankedKeywords(slice)
				doc = REXML::Document.new(endresult)
				proper_nouns << doc.each_element('//keywords//keyword//text//text()')			
			rescue
				puts "Couldnt get the Data."
			end
			
		end
		proper_nouns.flatten!
	else
		begin			
			endresult = alchemyObj.TextGetRankedKeywords(mytext)
			doc = REXML::Document.new(endresult)
			proper_nouns = doc.each_element('//keywords//keyword//text//text()')
		rescue
			puts "Couldnt get the Data 2"
		end
		
	end
	
	proper_nouns.each do |noun|
		noun = noun.to_s
		@umlauts.each_pair do |umlaut,entity|
			noun.gsub!(umlaut,entity)            
		end         		
		noun.gsub(/[^\w\s]/,"").split.each do |word|
			word = word.downcase
			word = word.gsub(/\d/,"")
			if word.size > 3 and !STOPWORDS.include?(word)
				stem = stemmer.stem(word)
				puts word
				if terms[stem] == nil 
					terms[stem] = Array.new(texts.size,0)
					terms[stem][i] = 1
				else
					terms[stem][i] = terms[stem][i]+1
				end
			end
		end
	end
end

#Export
puts "Exporting to CSV"
outfile = File.open("politiker_word_export.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|
    csv << ["id"] +  ["party"] + terms.keys #write header
    m = []
    m << person_names
    parties = []
    person_names.each do |name|
	    parties << PARTY[name.downcase]
    end
    m << parties
    terms.each do |k,v|
        vector  = terms[k]
        m << vector
    end
    m = m.transpose
    m.each do |row|
        csv << row
    end
end

outfile.close