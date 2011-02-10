class CreateListsTable < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.string :username
      t.string :list_type
      t.string :name
      t.integer :member_count
      t.integer :subscriber_count
      t.text :description
      t.string :uri
      t.string :slug
      t.integer :guid
    end
  end

  def self.down
    drop_table :lists
  end
  
end
