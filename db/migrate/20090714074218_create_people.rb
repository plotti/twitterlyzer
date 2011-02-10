class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :name      
      t.string :bio
      t.string :location
      t.string :time_offset

      t.binary :picture
      
      t.integer :friends_count
      t.integer :followers_count
      t.integer :statuses_count      
      t.integer :favourites_count
      t.integer :twitter_id

      t.string :website
      t.string :username
      t.string :lang
      t.string :time_zone
      t.boolean :private
      t.boolean :contributors_enabled
      t.boolean :geo_enabled
      t.boolean :verified
      
      t.date :last_activity
      t.date :acc_created_at
      
      #Last tweet
      t.integer:last_tweet_id
      t.date :last_tweet_date
      t.string :last_tweet_origin
      t.string :last_tweet_in_reply_to_screen_name
      
      #Fields to determine Roles
      t.string :role
      t.float :role_fit
      t.float :friending_fit
      
      t.float :d1
      t.float :d2
      t.float :d3
      t.float :d4
      t.float :d5
      t.float :d6
      t.float :d7
      t.float :d8
      t.float :e1
      
      
      t.timestamps
      
    end
  end

  def self.down
    drop_table :people
  end
end
