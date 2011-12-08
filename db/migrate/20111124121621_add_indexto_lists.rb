class AddIndextoLists < ActiveRecord::Migration
  def self.up
    add_index :lists, [:project_id]
  end

  def self.down
  end
end