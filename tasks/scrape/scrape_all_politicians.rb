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

  TWITTER_USERNAME = "plotti"
  TWITTER_PASSWORD = "wrzesz"
  
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
  
  social_networks = ["twitter", "twitter-0", "twitter-1", 
                     "facebook", "facebook-0", "facebook-1",
                     "meinvz", "studivz", "myspace", "wkw", "xing",
                     "flickr", "flickr-0", "youtube"]
  
  outfile = File.open("politiker.csv", 'w')

  CSV::Writer.generate(outfile) do |csv|
    csv << ["Partei", "Person", "Wahlkreis", "Listenplatz", "Webseite",            
            "Twitter 1", "Twitter 2", "Twitter 3",
            "Facebook 1", "Facebook 2", "Facebook 3",
            "MeinVZ", "StudiVZ", "MySpace", "WKW", "Xing",
            "Flickr 1", "Flickr 2", "Youtube"]
  end
  
  for seite in 0..SEITEN
    puts "WORKING ON PAGE: " + seite.to_s
    uri = URI.parse(URI.escape(BASE_URL + "/politiker" + "?page=" + seite.to_s))
    CSV::Writer.generate(outfile) do |csv|
      scraper.scrape(uri).each do |person|
        person_uri = URI.parse(URI.escape(BASE_URL + person.link))        
         
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
        
        social_uris = []          
        threads = []
        social_results = {}
        twitter_person = {}
        social_networks.each do |social_network|
          uri = URI.parse(URI.escape(BASE_URL + person.link + "/" + social_network))
          begin
            threads << Thread.new(uri,social_network){ |my_uri,my_social_network|
                                        begin
                                          social_results[my_social_network] = social_scraper.scrape(my_uri).to_s
                                          if social_results[my_social_network] != ""
                                            puts social_results[my_social_network]  
                                          end                                          
                                        rescue
                                          puts "error"
                                        end
                                        }              
          rescue
            puts "Timeout error:" + uri.to_s
            social_results[social_network] = ""
          end                      
        end

        threads.each do |a_thread|
          a_thread.join            
        end                         
        puts partei + " " + name + " " + person_details.wahlkreis + " " + person_details.listenplatz + " " + person_details.webseite.to_s      
        csv << [partei, name, person_details.wahlkreis, person_details.listenplatz, person_details.webseite,
                social_results["twitter"], social_results["twitter-0"],social_results["twitter-1"],
                social_results["facebook"], social_results["facebook-0"],social_results["facebook-1"],
                social_results["meinvz"],social_results["studivz"],
                social_results["myspace"],social_results["wkw"],social_results["xing"],
                social_results["flickr"],social_results["flickr-1"], social_results["youtube"]
                ]
      end
    end
  end
  outfile.close
  
end
