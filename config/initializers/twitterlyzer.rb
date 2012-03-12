## STRAPPING ###
require 'csv'
require 'grackle'
require 'twitter'
require 'rubygems'

#Constants
STOP_WORDS = File.new(RAILS_ROOT + "/public/stopwords.txt").readlines.map {|line| line.chomp}
FRIENDS_IDS_PATH = RAILS_ROOT + "/friends_ids_data/"
FOLLOWER_IDS_PATH = RAILS_ROOT  + "/follower_ids_data/"

#Bit Ly Api
BITLY_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/bitly.yml")
BITLY_LOGIN = BITLY_CONFIG["login"]
BITLY_API_KEY = BITLY_CONFIG["api_key"]

#Twitter Configs
TWITTER_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/twitter.yml")
CONSUMER_KEY = TWITTER_CONFIG["consumer_key"]
CONSUMER_SECRET = TWITTER_CONFIG["consumer_secret"]
ACCESS_TOKEN = TWITTER_CONFIG["access_token"]
ACCESS_TOKEN_SECRET = TWITTER_CONFIG["access_token_secret"]
TWITTER_USERNAME = TWITTER_CONFIG["login"]
TWITTER_PASSWORD = TWITTER_CONFIG["password"]

#Grackle Client
@@client = Grackle::Client.new(:auth=>{
  :type=>:oauth,
  :consumer_key=>CONSUMER_KEY, :consumer_secret=>CONSUMER_SECRET,
  :token=>ACCESS_TOKEN, :token_secret=>ACCESS_TOKEN_SECRET
})

#Twitter Client
Twitter.configure do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.oauth_token = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
end
@@twitter = Twitter

#read in cities hash
temp = Hash.new
CSV.read(RAILS_ROOT + '/public/cities_map.csv').each{|row| temp[row[0]] = row[1]}
CITIES_MAP = temp

#Uniq function
class Array
  def uniq_by
    seen = Set.new
    select{ |x| seen.add?(yield(x))}
  end
end

#Create dirs
FileUtils.mkdir_p FRIENDS_IDS_PATH
FileUtils.mkdir_p FOLLOWER_IDS_PATH