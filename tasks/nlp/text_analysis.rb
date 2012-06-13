require 'rubygems'
require 'lingua/stemmer'
require 'linalg'
require 'gnuplot'
require 'uri'

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
Person.all[0..200].each do |person|
	texts << person.get_all_entries.collect{|entry| entry.text + " "}.to_s
	person_names << person.username
end


#go through texts and tag, stem and stopwordremove
puts "Counting words"
texts.each_with_index do |mytext,i|
	puts "Analyzing Person #{i}"
	#Remove all uris from text
	URI.extract(mytext).each do |entry|
		mytext = mytext.sub(entry, "")
	end
	mytext.gsub(/[^\w\s]/,"").split.each do |word|
		word = word.downcase
		word = word.gsub(/\d/,"")
		if word.size > 8 and !STOPWORDS.include?(word)
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


#norm to frequencies

#i= 0 
#terms.each do |k,v|
# puts i.to_s
# vector = terms[k]
# vector.each_with_index do |element,i|
# 	vector[i] = vector[i].to_f / vector.max
# end
# terms[k] = vector
# i += 1
#end

#delete single occuring words
puts "Number of terms before reduction: #{terms.count}"
terms.each do |k,v|
	vector = terms[k]	
	if vector.sum < 5
		terms.delete(k)
	end
end
puts "Number of terms after reduction: #{terms.count}"

m = Linalg::DMatrix.new(terms.size,texts.size)

puts "Transforming into Matrix"
i= 0
terms.each do |k,v|
	vector  = terms[k]
	vector.each_with_index do |element,j|
		m[i,j] = vector[j]
	end
	i += 1
end

puts "Performing SVD"
u,s,vt = m.singular_value_decomposition
vt = vt.transpose

u2 = Linalg::DMatrix.join_columns [u.column(0), u.column(1)]
v2 = Linalg::DMatrix.join_columns [vt.column(0), vt.column(1)]
eig2 = Linalg::DMatrix.columns [s.column(0).to_a.flatten[0,2], s.column(1).to_a.flatten[0,2]]

puts "Plotting Graph"

Gnuplot.open do |gp|
 Gnuplot::Plot.new(gp) do |plot|
   plot.terminal "png size 1240,1028"
   
   plot.output "matrix.png"
   plot.data = []
   #plot.data << Gnuplot::DataSet.new([u2.column(0).to_a.flatten,u2.column(1).to_a.flatten]){ |ds|
   #	ds.title = "Words"
   #	ds.with = "points"
   # ds.linewidth = 2
   #}
   plot.data << Gnuplot::DataSet.new([v2.column(0).to_a.flatten,v2.column(1).to_a.flatten,person_names]){ |ds|
   	ds.with = "labels"
   	ds.title = "Twitter Users"
   	ds.linewidth = 2
   }
 end
end       																		       																		