class AddCategorytoPersons < ActiveRecord::Migration
  def self.up
    add_column :people, :category, :string
  end

  def self.down
  end
end
