#!/usr/bin/env ruby
#!/usr/bin/env ruby
require 'thread'
require 'rubygems'
require 'typhoeus'
require 'json'
require "base64"
require 'csv'
require 'uri'
require 'simple-rss'
include Typhoeus

# Deprecated since Twitter has another API since 2010

class CollectTwitterAccounts < Struct.new(:text)
  
  def self.get_urls (text)
    a = text.gsub(/((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/).to_a   
  end
  
  def self.get_expanded_urls (text)
      results = []
      if get_urls(text) != []    
        get_urls(text).each do |url|     
          if URI.parse(url).host == "bit.ly"
            begin
              tmp_res = self.expand_url(:params => {:shortUrl => url})
            rescue
            end
            if tmp_res != nil
              temp = tmp_res["results"]
              errorcode = tmp_res["statusCode"]          
              if errorcode != "ERROR"
                if temp != nil                 
                  key = temp.keys.first
                  results << temp[key]["longUrl"]
                end
              end
            end        
        else
          results << url
          end
        end      
      end
      return results
  end
 
  TWITTER_USERNAME = ""
  TWITTER_PASSWORD = ""
  BITLY_LOGIN = ""
  BITLY_API_KEY = ""
  
  define_remote_method :twitter_user, :path => '/users/show.json',:headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"},
                       :on_success => lambda {|response| JSON.parse(response.body)},
                       :on_failure => lambda {|response| puts "error code: #{response.code}" },
                       :base_uri   => "http://twitter.com"
  
  define_remote_method :user_timeline, :path => '/statuses/user_timeline.rss',
                       :base_uri => "http://twitter.com",
                       :on_success => lambda {|response| SimpleRSS.parse(response.body)},
                       :on_failure => lambda {|response| puts "error code: #{response.code}"},
                       :headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"}

  define_remote_method :expand_url, :path =>'http://api.bit.ly/expand',
                       :params => {:version => "2.0.1", :login => BITLY_LOGIN, :apiKey => BITLY_API_KEY},
                       :on_success => lambda{|response| JSON.parse(response.body)},
                       :on_failure => lambda{|response| puts "error code: #{response.code}"}

                        
  if ARGV.length != 1
    puts "usage: collect_twitter_csv_accounts.rb file.csv"
    exit
  end
  
  csv_file = ARGV[0]
  
  twitter_ids = []
  CSV::Reader.parse(File.open(csv_file, 'rb')) do |row  |
    twitter_ids <<  URI.parse(row.to_s).path.reverse.chop.reverse
  end

  outfile = File.open(csv_file + "_stats.csv",'w')

  CSV::Writer.generate(outfile) do |csv|
    csv << ["Twitter ID", "Username", "Friends", "Followers", "Messages", "Created_At",
            "Description", "Favorites_count", "TimeZone", "Location", "Url", "Protected", "Geo",
            "Verified", "Last_Tweet", "Last_Tweet_Date", "Links_in_Tweet", ]
  end

  CSV::Writer.generate(outfile) do |csv|
    i = 0
    twitter_ids.each do |id|
      i = i+1
      begin
        twitter_user =  self.twitter_user(:params => {:id => id})
        last_tweet = self.user_timeline(:params => {:id => id}).entries.first
        puts id.to_s + " found. (" + i.to_s + "/" + twitter_ids.count.to_s + ")"
        csv << [twitter_user['id'], twitter_user['screen_name'], twitter_user['friends_count'],
             twitter_user['followers_count'], twitter_user['statuses_count'], Date.parse(twitter_user['created_at']).to_s,
             twitter_user['description'], twitter_user['favorites_count'], twitter_user['time_zone'],
             twitter_user['location'], twitter_user['url'], twitter_user['protected'], twitter_user['geo_enabled'],
             twitter_user['verified'], last_tweet.title, last_tweet.pubDate, get_expanded_urls(last_tweet.title)]
      rescue
       puts id.to_s + " not found. (" + i.to_s + "/" + twitter_ids.count.to_s + ")"
      end
    end
  end   



end