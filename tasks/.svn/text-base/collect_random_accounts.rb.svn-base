#!/usr/bin/env ruby
require 'thread'
require 'rubygems'
require 'typhoeus'
require 'json'
require "base64"
require 'csv'
include Typhoeus
  
class CollectRandomTwitterAccounts < Struct.new(:text)
 
  TWITTER_USERNAME = "plotti"
  TWITTER_PASSWORD = "wrzesz"
  IDS = 50000000
  
  define_remote_method :twitter_user, :path => '/users/show.json',:headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"},
                       :on_success => lambda {|response| JSON.parse(response.body)},
                       :on_failure => lambda {|response| puts "error code: #{response.code}" },
                       :base_uri   => "http://twitter.com"
                       
  

  puts "WURST"  
  outfile = File.open("random_accounts.csv", 'w')  

  CSV::Writer.generate(outfile) do |csv|
    csv << ["Exists", "Twitter ID", "Username", "Friends", "Followers", "Messages", "Created At",
            "Description", "Favorites_count", "TimeZone", "Location", "Url", "Protected", "Geo",
            "Verified"]
  end

  threads = []
  
  CSV::Writer.generate(outfile) do |csv|
    while true
      id = rand(50000000)
      begin
        twitter_user =  self.twitter_user(:params => {:id => id})
        puts id.to_s + " found. (T: " + Thread.list.count.to_s + ")"
        csv << ["1", twitter_user['id'], twitter_user['screen_name'], twitter_user['friends_count'],
             twitter_user['followers_count'], twitter_user['statuses_count'], twitter_user['created_at'],
             twitter_user['description'], twitter_user['favorites_count'], twitter_user['time_zone'],
             twitter_user['location'], twitter_user['url'], twitter_user['protected'], twitter_user['geo_enabled'],
             twitter_user['verified']]
      rescue
        #csv << ["0", id.to_s]
      end
    end
  end   

end