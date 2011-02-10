class CollectTwitterAccounts < Struct.new(:text)
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  
  uris = []
  BASE_URL = "http://wefollow.com/twitter/"
  
  search_words = %w(ruby python java abap)
  
  scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "#results>div", :items => Scraper.define {
      #process "div", :name => :text
      process "div.result_row>div.result_details>p>strong>a", :name => :text     
    }    
    result :items
  end

  PAGES = 10
  
  outfile = File.open("languages.csv", 'w')  
  
  CSV::Writer.generate(outfile) do |csv|
     #csv << ["Twitter User", "Language"]
  end
 
  CSV::Writer.generate(outfile) do |csv|
    search_words.each do |word|      
      for page in 1..PAGES
        if page == 1
          uri = URI.parse(BASE_URL + word ) 
        else
          uri = URI.parse(BASE_URL + word + "/page#{page}")   
        end        
        puts uri
        begin
          scraper.scrape(uri).each do |person|
            result_string = "http://twitter.com/" + person.name
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

