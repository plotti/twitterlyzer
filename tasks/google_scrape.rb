require 'csv'
require 'rubygems'  
require 'typhoeus'
require 'scrapi'
require 'uri'
require "base64"
require 'json'
include Typhoeus

class CollectTweets 

	TWITTER_USERNAME = "plotti"
	TWITTER_PASSWORD = "wrzesz"	
	BASE_URL = "http://www.google.de/search?"	
	search_query = "sherlock+holmes"
	site_parameters = "&as_q=site%3Atwitter.com" 	
	safe_parameters = "&safe=off&filter=0&pws=0"	
	RPP = 100
	rpp_string = "&num=#{RPP}"
	SEARCH_QUERY_STRING = "as_q=#{search_query}" + site_parameters  + rpp_string + safe_parameters
	PAGES = 9		
	starting_month = 10
	ending_month = 11
	year = 2009

	define_remote_method  :get_status, :path => '/statuses/show.json',
                          :base_uri => "http://twitter.com",
                          :on_success => lambda {|response| JSON.parse(response.body)},
                          :on_failure => lambda {|response| puts "error code: #{response.code}"},
                          :headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"}

	def get_tweets(starting_month, ending_month, year)

		@scraper = Scraper.define do
			array :items
			process "li", :items => Scraper.define {
				process "a.l", :link => "@href"      
			}    
			result :items
		end

		results = []	
		for day in 1..31
			for month in starting_month..ending_month
				puts "Parsing Month:#{month}"
				date_range_string="&tbs=cdr%3A1%2Ccd_min%3A#{day}.#{month}.#{year}%2Ccd_max%3A#{day}.#{month+1}.#{year}"
				for page in 0..PAGES
					print page.to_s + " "
					STDOUT.flush
					tmp_results = []
					start_string = "&start=#{page*RPP}"
					uri = URI.parse(BASE_URL + SEARCH_QUERY_STRING  + start_string + date_range_string)
					@scraper.scrape(uri).each do |result|
						results << result.link
					end
				end
			end
		end
				
		filtered_results = []
		results.uniq!
		results.each do |result|
			if result.include?("status") or result.include?("status")
				filtered_results << result
				puts result
			end			
		end
		puts "Months from #{starting_month} to #{ending_month} of year #{year}"
		puts "Results" + results.count.to_s	
		puts "Filtered Results"  + filtered_results.count.to_s
		return filtered_results
	end

end

c = CollectTweets.new
	
r1 = c.get_tweets(11,11,2009)
#r2 = c.get_tweets(1,4,2010)
results = r1 #+ r2
#results = c.get_tweets(1,1,2010)
outfile = File.open("sherlock_december_tweets.csv", 'w')  

CSV::Writer.generate(outfile) do |csv|
	csv << ["Tweet Url", "Text", "User", "Created At"]
end

CSV::Writer.generate(outfile) do |csv|
	results.each do |result|
		tweet_id = URI.parse(result).path.gsub(/\d+/).first
		begin
			tweet = CollectTweets.get_status(:params => {:id => tweet_id})
			date = Date.parse(tweet['created_at'])
			datestring = "#{date.day}.#{date.month}.#{date.year}"
			csv << [result, tweet['text'], tweet['user']['screen_name'],datestring]
		rescue
			"Couldnt get tweet for #{result}"
		end
	end
end

outfile.close
