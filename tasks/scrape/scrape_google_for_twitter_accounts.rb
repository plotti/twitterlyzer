class CollectTwitterAccounts < Struct.new(:text)
	require 'rubygems'  
	require 'nokogiri'  
	require 'csv'
	require 'cgi'
	require 'open-uri' 
	
	BASE_URL = "http://www.google.de/search?"
	
	search_query = "invictus"
	site_parameters = "&as_q=site%3Atwitter.com" 	
	safe_parameters = "&safe=off&filter=0&pws=0"	
	months = 1
	rpp = 100
	rpp_string = "&num=#{rpp}"
	search_query_string = "as_q=#{search_query}" + site_parameters  + rpp_string + safe_parameters
	PAGES = 9
		

	results = []	
	for month in 1..months
		date_range_string="&tbs=cdr%3A1%2Ccd_min%3A01.#{month}.2010%2Ccd_max:01.#{month+1}.2010"
		for page in 0..PAGES
				tmp_results = []
				start_string = "&start=#{page*rpp}"
				uri = URI.parse(BASE_URL + search_query_string  + start_string + date_range_string)				
				puts uri.to_s
				doc = Nokogiri::HTML(open(uri))  
				doc.css("li").each do |item|  
					puts item.at_css(".l").href  
				end  		
		end
	end
	
	filtered_results = []
	results.each do |result|
		if result.include?("status")
			filtered_results << result
			puts result
		end
	end
	
	puts "Results" + results.count.to_s	
	puts "Filtered Results"  + filtered_results.count.to_s
	
end
