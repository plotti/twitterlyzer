class CollectTwitterAccounts < Struct.new(:text)
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  
  uris = []
  BASE_URL = "http://www.delicious.com/search?"
  
  #search_words = ARGV[0]
  search_words = []
  rows = CSV.read("../data/wefollow_keywords.txt")
  rows.each do |row|
    search_words << row[0]
  end
  
  
  scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "#srpRelated>div.tagdisplay>ul>li", :items => Scraper.define {
      process "a", :name => :text     
    }    
    result :items
  end
    
  outfile = File.open("../data/wefollow_net.csv", 'w')  
  
  CSV::Writer.generate(outfile) do |csv|
     #csv << ["Twitter User", "Language"]
  end
 
  CSV::Writer.generate(outfile) do |csv|
    search_words.each do |word|
      puts "########### Analyzing word #{word} ###########"
      uri = URI.parse(BASE_URL + "+p=#{word}")      
      begin
        scraper.scrape(uri).each do |tag|          
          puts tag.name
          csv << [word,tag.name,"1"]
        end
      rescue
        puts "Couldnt find any page for #{uri}"
      end
    end 
  end
  
  outfile.close

end

