class AddUsernameIndexToPersons < ActiveRecord::Migration
  def self.up
    add_index :people, [:username]
  end

  def self.down
  end
end