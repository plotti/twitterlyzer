class AddIndextoDelayedJob < ActiveRecord::Migration
  def self.up
    add_index :delayed_jobs, [:priority, :run_at],  :order => {:priority => :desc, :run_at => :asc}
    
  end

  def self.down
  end
end
