class ScrapeGoogle < Struct.new(:text)
	require 'rubygems' 
	require 'hpricot'
	require 'net/http'
	  require 'cgi'
	
	#def self.get_results(searchquery)
		proxy_host = '96.239.16.216'
		proxy_port = 3128
		
		pagerange = 1..10
		months = 1
		search_query = "invictus"
		additional_parameters="+site%3Atwitter.com+inurl%3Astatus"
		search_query_string = "as_q=#{search_query}" + additional_parameters 
		rpp = 100
		rpp_string = "&num=#{rpp}"

		results = []
		old_results = ""
		proxy = Net::HTTP::Proxy(proxy, proxy_port)		
		for month in 1..months
			date_range_string="&tbs=cdr%3A1%2Ccd_min%3A01.#{month}.2010%2Ccd_max:01.#{month+1}.2010"
			skippages = false
			puts "Month" + month.to_s
			proxy.start('www.google.de') do |http|
				pagerange.each do |page|					
					tmp_results = []
					if skippages == false
						puts "Page"  + page.to_s
						start_string = "&start=#{page*rpp}"
						url_string = "/search?"+search_query_string+start_string+rpp_string+date_range_string		
						puts url_string
						resp, data = http.get url_string
						if resp.class == Net::HTTPOK											
							if (Hpricot(data)/"li[@class='g'] a[@class='l']").count == 0
								skippages = true
							end
							(Hpricot(data)/"li[@class='g'] a[@class='l']").each do |a|								
								tmp_results << a.attributes['href']
								if old_results.first == a.attributes['href']
									skippages = true
								end
								puts a
								results << a.attributes['href']
							end
						end
					end
					old_results = tmp_results
				end
			end 
		end

		filtered_results = []
		results.uniq!
		results.each do |result|
			if result.include?("status")
				filtered_results << result
				#puts result
			end
		end
		puts filtered_results.count.to_s

	#end
	
end
