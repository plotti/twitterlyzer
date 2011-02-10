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
    process "div.logo+div.yui-u", :items => Scraper.define {  
      process "h4>a", :name => :text  
      process "tr.wahlkreis>td.position", :wahlkreis => :text
      process "tr+tr>td.position", :listenplatz => :text
      result :name, :wahlkreis, :listenplatz  
    }  
    result :items  
  end
  
  social_scraper = Scraper.define do  
    process "a.external", :social_account => "@href"
    result :social_account
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
  
  POLITIKER_BASE_URL = "http://www.wahl.de/politiker/"
  BASE_URL = "http://www.wahl.de/kandidaten/bundestag/"
  
  #parteien = ["grüne","cdu","spd","fdp","die+linke",]
  parteien = ["fdp","die+linke",]
  laender = ["baden-württemberg","bayern","berlin","brandenburg",
             "bremen","hamburg","hessen","mecklenburg-vorpommern",
             "niedersachsen","nordrhein-westfalen","rheinland-pfalz","saarland",
             "sachsen","sachsen-anhalt","schleswig-holstein","thüringen"]

  social_networks = ["twitter", "facebook", "meinvz", "studivz", "myspace", "wkw", "xing", "flickr" ]
  
  outfile = File.open("/home/thomas/socialyzer/lib/wahlliste.csv", 'w')  

  CSV::Writer.generate(outfile) do |csv|
    csv << ["Partei", "Land", "Person", "Wahlkreis", "Listenplatz", "Twitter-Account", "Friends", "Follower", "Messages", "Facebook", "MeinVZ", "StudiVZ", "MySpace", "WKW", "Xing", "Flickr"]
  end
  
  parteien.each do |partei|
    uris = []
    laender.each do |land|  
      uri = URI.parse(URI.escape(BASE_URL + "/" + land + "/" + partei))
      CSV::Writer.generate(outfile) do |csv|
        scraper.scrape(uri).each do |person|
          @umlauts.each_pair do |umlaut,entity|
            person.name.gsub!(umlaut,entity)
            person.wahlkreis.gsub!(umlaut,entity)
            person.listenplatz.gsub!(umlaut,entity)
          end         
          
          tmp_name = person.name.downcase.gsub(" ","-").gsub("dr.-","")
          tmp_partei = partei.gsub("+","-")
          transform.each_pair do |umlaut,entity|
            tmp_name.gsub!(umlaut,entity) 
            tmp_partei.gsub!(umlaut,entity)  
          end
          
          social_uris = []          
          threads = []
          social_results = {}
          twitter_person = {}
          social_networks.each do |social_network|
            uri = URI.parse(URI.escape(POLITIKER_BASE_URL + tmp_partei + "/" + tmp_name + "/" + social_network))
            begin
              threads << Thread.new(uri,social_network){ |my_uri,my_social_network|
                                          begin
                                            social_results[my_social_network] = social_scraper.scrape(my_uri).to_s
                                            puts social_results[my_social_network]
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
                    
          if social_results["twitter"] != ""
              begin
                #username = URI.parse(twitter_entry).path.reverse.chop.reverse
                username = social_results["twitter"].slice(social_results["twitter"].rindex("/")+1,social_results["twitter"].length)
                twitter_person = CollectWahllisten.twitter_user(:params => {:id => username})
                puts "USER" + username + twitter_person['friends_count'].to_s + " " + twitter_person['followers_count'].to_s + " " + twitter_person['statuses_count'].to_s
              rescue
                twitter_person = {}
                puts social_results["twitter"] + " not found."
              end            
          end
          puts partei + " " + land + " " + person.name + " " + person.wahlkreis + " " + person.listenplatz + " " + social_results["twitter"] + " " 
          csv << [partei, land, person.name, person.wahlkreis, person.listenplatz,
                  social_results["twitter"], twitter_person['friends_count'], twitter_person['followers_count'],twitter_person['statuses_count'],
                  social_results["facebook"],social_results["meinvz"],social_results["studivz"],
                  social_results["myspace"],social_results["wkw"],social_results["xing"],social_results["flickr"]]
        end
      end
    end  
  end
  outfile.close
  
end