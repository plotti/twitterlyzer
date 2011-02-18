class AddIndextoRetweetCount < ActiveRecord::Migration
  def self.up
    add_index :feed_entries, [:retweet_count]
  end

  def self.down
  end
end
