class AddFieldstoFeeds < ActiveRecord::Migration
  def self.up
    add_column :feed_entries, :place, :string
    add_column :feed_entries, :in_reply_to_user_id, :string
    add_column :feed_entries, :retweeted, :string
    add_column :feed_entries, :retweet_count, :string
    add_column :feed_entries, :contributors, :string
    add_column :feed_entries, :favorited, :string
    add_column :feed_entries, :truncated, :string
    add_column :feed_entries, :coordinates, :string
    add_column :feed_entries, :source, :string
  end

  def self.down
    add_column :feed_entries, :place
    add_column :feed_entries, :in_reply_to_user_id
    add_column :feed_entries, :retweeted
    add_column :feed_entries, :retweet_count
    add_column :feed_entries, :contributors
    add_column :feed_entries, :favorited
    add_column :feed_entries, :truncated
    add_column :feed_entries, :coordinates
    add_column :feed_entries, :source
  end
  
end
