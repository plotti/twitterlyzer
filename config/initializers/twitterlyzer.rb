## STRAPPING ###
require 'rubygems'
require 'csv'
require 'grackle'
require 'twitter'
require 'faster_csv'

#Communities
#@@communities = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
#@@communities = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181]

# Communities gathered in a first attempt by using the most popular wefollow keywords
keywords_from_wefollow = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155]

# Communities gathered with the help of precollected sorted members lists
keywords_from_backup = [157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 170, 171, 172, 174, 175, 176, 177, 178, 179, 180, 181]
#excluded because of irrelevance [168,169,173]

# Collection of Communities after the creation of a interesed map by combining yahoo and wefollow
keywords_after_yahoo = [183, 185, 187, 189, 191, 193, 195, 197, 199, 201, 203, 205, 207, 209, 211, 213, 215, 217, 219, 221, 223, 225, 227, 229, 231, 233, 235, 237, 239, 241, 243, 245, 247, 249, 251, 253, 255, 257, 259, 261, 263, 265, 267, 269, 271, 273, 275, 277, 279, 281, 283, 285, 287, 289, 291, 293, 295, 297, 299, 301, 303, 305, 307, 309, 311, 313, 315, 317, 319, 321, 323, 325, 327, 329, 331, 333, 335, 337, 339, 341, 343, 345, 347, 349, 351, 353, 355, 357, 359, 361, 363, 365, 367, 369, 371, 373, 375, 377, 379, 381, 383, 385, 387, 389, 391, 393, 395, 397, 399, 401, 403, 405, 407, 409, 411, 413, 415, 417, 419, 421, 423, 425, 427, 429, 431, 433, 435, 437, 439, 441, 443, 445, 447, 453, 455, 457, 461, 463, 465, 467, 469]
# Gaming Removed because double entry 106 and 471. 106 has 100 match with gaming sorted list
# Fashion Removed because double entry 102 and 473. 102 has 100 match with gaming sorted list
# Publishing Removed because double entry 56 and 119. 119 has 75 match with gaming sorted list

# For a number of communities that had less than 10 lists we tried to recollect those
recollected_lists_for_small_communities = [485, 487, 489, 491, 493, 495, 497, 499, 501, 503, 505, 507, 509, 511, 513, 515, 517, 519, 521, 523, 525, 527, 529, 531, 533, 535, 537, 539, 541, 543, 545, 547, 549, 551, 553, 555, 557, 559, 561, 563, 565, 567, 569, 571, 573, 575, 577, 579, 581]
#These communities have been replaced with the above
replaced_communities = [249, 377, 185, 239, 345, 347, 229, 283, 381, 235, 277, 205, 269, 287, 383, 199, 201, 215, 301, 153, 197, 203, 321, 183, 237, 241, 393, 299, 309, 343, 243, 335, 429, 223, 231, 267, 295, 193, 289, 195, 227, 273, 331, 375, 409, 225, 313, 349, 363]

# After the recollection some communities still did not have enough lists (<10) Those are removed
communities_with_not_enough_lists = [191, 477, 249, 485, 345, 493, 347, 495, 381, 501, 377, 487, 235, 503, 205, 507, 383, 513, 203, 527, 199, 515, 301, 521, 269, 509, 335, 547, 185, 489, 429, 549]

# Keywords that have a strange distribution because the lists have been spammed
spammed_keywords = [137,457]

@@communities = keywords_from_wefollow + keywords_from_backup + keywords_after_yahoo  + recollected_lists_for_small_communities  - communities_with_not_enough_lists - replaced_communities

@@community_map = {}
if ENV["RAILS_ENV"] == "development"
  @@communities.each{|c| @@community_map[Project.find(c).name] = Project.find(c).id}
end

#Blacklist
BLACKLIST = FasterCSV.read("#{RAILS_ROOT}/config/blacklist.csv").flatten

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

#Lists Config
MAXIMUM_LISTS_PER_USER = 10000
LIST_PAGE_SIZE = 400

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