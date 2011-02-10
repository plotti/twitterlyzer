class CollectTwitterAccounts < Struct.new(:text)
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  
  uris = []
  POLITIKER_BASE_URL = "http://www.wahl.de/politiker/"
  
  transform = {
    'ü' => 'ue',
    'Ü' => 'ue',
    'ä' => 'ae',
    'Ä' => 'ae',
    'ö' => 'oe',
    'Ö' => 'oe'
  }
  
  twitter_scraper = Scraper.define do  
    process "a.external", :twitter_account => "@href"
    result :twitter_account
  end  
  
  rows = CSV.read("/home/thomas/socialyzer/lib/wahlliste.csv")
  rows.each do |row|
    name = row[2].downcase.gsub(" ","-").gsub("dr.-","")
    partei = row[0].gsub("+","-")
    umlauts.each_pair do |umlaut,entity|
      partei.gsub!(umlaut,entity) 
      name.gsub!(umlaut,entity)  
    end  
    uris << POLITIKER_BASE_URL + partei + "/" + name + "/twitter"
  end
  
  uris.each do |uri|  
    uri = URI.parse(uri)
    puts "URI" + uri.to_s + " TWITTER: " + scraper.scrape(uri).to_s
  end

end

