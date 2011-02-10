module FeedEntriesHelper

  def auto_link_username(tweet)
    auto_link tweet.gsub(/@(\w+)/, %Q{@<a href="http://twitter.com/\\1">\\1</a>})
  end
  
  
end
