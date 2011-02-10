class AddUniqueToFriendShips < ActiveRecord::Migration
#  def self.up
#    #execute "ALTER TABLE 'friendships' ADD UNIQUE 'friendships_linked_id' ('person','followed_by_person')"
#    execute "CREATE UNIQUE INDEX friendships_linked ON friendships (person, followed_by_person)"
#  end
#
#  def self.down    
#  end
end
