class Search < ActiveRecord::Base
  require 'json'
  require 'typhoeus'
  include Typhoeus
  
  MAX_FRIENDS = 100000
  
  belongs_to :projects
  has_many :search_results, :dependent => :destroy
   
  define_remote_method :get_searches_atom, :path => "http://search.twitter.com/search.atom",
                       :on_success => lambda {|response| SimpleRSS.parse(response.body)},
                       :on_failure => lambda {|response| puts "error code: #{response.code}"},
                       :headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"}

  define_remote_method :get_searches_json, :path => "http://search.twitter.com/search.json",
                         :on_success => lambda {|response| JSON.parse(response.body)},
                         :on_failure => lambda {|response| puts "error code: #{response.code}"},
                         :headers => {"Authorization" => "Basic #{Base64.b64encode(TWITTER_USERNAME + ":" + TWITTER_PASSWORD)}"}
                       
  def collect_search_results 
    page = 1
    more_entries_exist = true
    entries_to_add = []
    
    
    if self.search_results != []
      latest_search_entry = self.search_results.maximum("published_at")
    else
      latest_search_entry = Date.new
    end

    while more_entries_exist
      
      puts "getting page " + page.to_s
      found_entries = []
      begin
        found_entries = Search.get_searches_json(:params => {:q => self.search_query, :rpp => 100, :page => page})['results']
      rescue
        puts "No entries found for : " + self.search_query.to_s
        found_entries = []
        more_entries_exist = false
      end
      
      #stop if the found entries are older than what we already have
      found_entries.each do |found_entry|
        if Date.parse(found_entry['created_at'].to_s) < latest_search_entry
          more_entries_exist = false
        end
      end
      
      #transfer entries and go to next page
      found_entries.each do |entry|
        entries_to_add << entry
      end      
      page += 1
    
    end

    entries_to_add.each do |entry|
      if SearchResult.all(:conditions => ["feed_entry_guid = ? ", entry['id']]) == []
        SearchResult.create!(      
          :search_id => self.id,    
          :feed_entry_guid => entry['id'],
          :pubDate => entry['created_at'],
          :twitter_username => entry['from_user']     
        )        
      end
    end
    
  end
  
end
