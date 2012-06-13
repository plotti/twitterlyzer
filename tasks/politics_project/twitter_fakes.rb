#!/usr/bin/env ruby
class CollectWahllisten < Struct.new(:text)
  
  require 'rubygems'  
  require 'scrapi'
  require 'csv'
  require 'cgi'
  require 'typhoeus'
  require 'json'
  require "base64"
  include Typhoeus

  TWITTER_USERNAME = ""
  TWITTER_PASSWORD = ""
  
  define_remote_method :twitter_user, :path => '/users/show.json',:headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"},
                       :on_success => lambda {|response| JSON.parse(response.body)},
                       :on_failure => lambda {|response| puts "error code: #{response.code}" },
                       :base_uri   => "http://twitter.com"
  
  scraper = Scraper.define do  
    array :items  
    process "tbody>tr", :items => Scraper.define {  
      process "td.views-field-title>a", :link => "@href"
    }  
    result :items  
  end
  
  fake_scraper = Scraper.define do
    array :items
    process "li.jcarousel-item", :items => Scraper.define {
      process "div.fake>div.service-logo>a", :social_account => "@href"
    }
    result :items
  end  
  
  social_scraper = Scraper.define do  
     process "a.external", :social_account => "@href"
    result :social_account
  end
    
  base_scraper = Scraper.define do
    
    process "div.yui-gc>div.first>table:first-of-type>tr>td", :wahlkreis => :text
    process "table+table td.position", :listenplatz => :text    
    process "div+div>dl>dd>a", :webseite => "@href"
    process "a.active", :name => :text
    result :name, :wahlkreis, :listenplatz, :webseite
  end
  
  @umlauts = {
    '&uuml;' => 'ü',
   '&auml;' => 'ä',
   '&ouml;' => 'ö',
   '&Uuml;' => 'Ü',
   '&Auml;' => 'Ä',
   '&Ouml;' => 'Ö',
   '&szlig;' => 'ß',
   '&#39;' => "'"  
  }
  
  transform = {
    'ü' => 'ue',
    'Ü' => 'ue',
    'ä' => 'ae',
    'Ä' => 'ae',
    'ö' => 'oe',
    'Ö' => 'oe',
    'ß' => 'ss'
  }
  
  BASE_URL = "http://www.wahl.de"
  SEITEN = 132
   
  outfile = File.open("fakes.csv", 'w')

  CSV::Writer.generate(outfile) do |csv|
    csv << ["Partei", "Person", "Wahlkreis", "Listenplatz", "Webseite",            
            "Twitter ", "Twitter 2", "Twitter 3",
            "Fake ", "Fake 2", "Fake 3"]
  end
  
  for seite in 0..SEITEN
    puts "WORKING ON PAGE: " + seite.to_s    
    uri = URI.parse(URI.escape(BASE_URL + "/politiker" + "?page=" + seite.to_s))
    
    CSV::Writer.generate(outfile) do |csv|
      scraper.scrape(uri).each do |person|
        person_uri = URI.parse(URI.escape(BASE_URL + person.link))        
        fake_tweets = fake_scraper.scrape(person_uri)
        begin          
          person_details = base_scraper.scrape(person_uri)          
          @umlauts.each_pair do |umlaut,entity|
            person_details.name.gsub!(umlaut,entity)
          end
        rescue
          puts "Timeout error while scraping details..."
        end
              
        partei = person_details.name.slice(person_details.name.rindex("(")+1,person_details.name.rindex(")")-person_details.name.rindex("(")-1)
        name = person_details.name.slice(0,person_details.name.rindex("(")-1)
        
        begin
          fake_tweets.each do |entry|
            fake_uri = social_scraper.scrape(URI.parse("http://www.wahl.de" + entry.social_account))            
            puts "Person " + name.to_s + " Fake ist account: " + fake_uri
            csv << [name, fake_uri]
          end
        rescue
          #puts "Error finding fake accounts"
        end        
      end
    end
  end
  outfile.close
  
end
