class CollectTwitterAccounts < Struct.new(:text)
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  
  uris = []
  BASE_URL = "http://muckrack.com/"
  
  newspapers = %w(abcnews ap ars bbc bizinsider bizweek cbsnews chicagotrib cnet 
            cnn dsc fc forbes fortune fox ft guardian huffpo independent 
            latimes msnbc nbcnews npr nyt paidcontent pcworld reason reuters 
            si telegraph time timeslondon usatoday washpost wired wsj zdnet)
  
  scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "div+div>div.person-box", :items => Scraper.define {
      process "div>a.likeit_button", :name => "@onclick"      
    }    
    result :items
  end

  
  outfile = File.open("journalists.csv", 'w')  
  
  CSV::Writer.generate(outfile) do |csv|
     csv << ["Journalist", "Newspaper"]
  end
 
  CSV::Writer.generate(outfile) do |csv|
    newspapers.each do |newspaper|
      uri = URI.parse(BASE_URL + newspaper + "/people")   
      scraper.scrape(uri).each do |person|
        result_string = person.name
        name = result_string.gsub(/'(.*?)'/).first.gsub(/'/, "")
        csv << [name, newspaper.to_s]
      end
    end
  end
  
  outfile.close

end

