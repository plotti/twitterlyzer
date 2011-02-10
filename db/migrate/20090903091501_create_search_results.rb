class CreateSearchResults < ActiveRecord::Migration
  def self.up
     create_table :search_results do |t|
      t.string :search_id
      t.string :feed_entry_guid
      t.string :twitter_username
      t.date   :pubDate
      
      t.timestamps
    end
  end

  def self.down
    drop_table :searches
  end
end
