class ProjectPeople < ActiveRecord::Migration  
  def self.up
    create_table :people_projects, :id => false do |t|
      t.integer :project_id
      t.integer :person_id
    end
  end

  def self.down
    drop_table :people_projects
  end
end
