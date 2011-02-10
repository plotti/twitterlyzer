class CollectTwitterAccounts < Struct.new(:text)
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  
  uris = []
  BASE_URL = "http://twellow.com/category_users/cat_id/"
   
  scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "table.listings-border", :items => Scraper.define {
      process "i>a", :name => "@href"
    }    
    result :items
  end

  subcategory_scraper = Scraper.define do  
    array :items
    process "table.twellow-tools li", :items => Scraper.define {
        process "a", :name => :text
      }    
    result :items
  end
  
  category_scraper = Scraper.define do
    process "div.user-amount", :category=> :text
    result :category
  end
  CATEGORIES = 3100
  
  outfile = File.open("twellow.csv", 'w')  
  
  CSV::Writer.generate(outfile) do |csv|
     csv << ["Twitter User", "Category", "Id"]
  end
 
  CSV::Writer.generate(outfile) do |csv|
    for category in 1..CATEGORIES
      uri = URI.parse(BASE_URL + category.to_s)      
      puts uri
      begin
        catagory_string = category_scraper.scrape(uri).to_s
        #category_scraper.scrape(uri)
        #subcategory_scraper.scrape(uri).each do |sub_category|
        #  puts sub_category.name
        #end
        scraper.scrape(uri).each do |person|
          result_string = person.name
          puts result_string
          #name = result_string.gsub(/'(.*?)'/).first.gsub(/'/, "")
          csv << [result_string, catagory_string, category.to_s]
          #csv << [result_string]
        end
      rescue
        puts "Couldnt find any page for #{uri}"
      end
    end
  end
  
  outfile.close

end

