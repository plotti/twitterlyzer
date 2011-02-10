class AddReplytoFeeds < ActiveRecord::Migration
  def self.up
    add_column :feed_entries, :reply_to, :string
  end

  def self.down
  end
end
