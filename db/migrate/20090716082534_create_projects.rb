class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.string :description
      t.string :keyword
      t.boolean :monitor_feeds
      t.boolean :monitor_people
      t.boolean :monitor_searches
      
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
