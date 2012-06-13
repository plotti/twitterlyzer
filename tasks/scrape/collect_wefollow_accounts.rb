#Scrapes Wefollow according to a certain keyword

class CollectTwitterAccounts < Struct.new(:text)
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  
  uris = []
  BASE_URL = "http://wefollow.com/twitter/"
  
  search_words = ARGV[0]
  
  scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "#results>div", :items => Scraper.define {
      process "div.result_row>div.result_details>p>strong>a", :name => :text     
    }    
    result :items
  end

  PAGES = 25
  
  outfile = File.open("../data/#{ARGV[0]}.csv", 'w')  
  
  CSV::Writer.generate(outfile) do |csv|
     #csv << ["Twitter User", "Language"]
  end
 
  CSV::Writer.generate(outfile) do |csv|
    search_words.each do |word|      
      for page in 1..PAGES
        if page == 1
          uri = URI.parse(BASE_URL + word + "/followers") 
        else
          uri = URI.parse(BASE_URL + word + "/page#{page}" + "/followers")   
        end        
        puts uri
        begin
          scraper.scrape(uri).each do |entry|
            name = entry.name
            puts result_string
            #name = result_string.gsub(/'(.*?)'/).first.gsub(/'/, "")
            #csv << [result_string, word.to_s]
            csv << [result_string]
          end
        rescue
          puts "Couldnt find any page for #{uri}"
        end
      end
    end 
  end
  
  outfile.close

end