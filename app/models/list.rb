class List < ActiveRecord::Base
  serialize :members
  belongs_to :project
  
  def self.collect_list_members(list_id)
    @list = List.find(list_id)
    result = @@twitter.list_members(@list.username, @list.guid, {:cursor => -1})    
    members = result["users"]
    next_cursor = result["next_cursor"]
    old_next_cursor = 0    
    @list.members = []
    @list.save!
    
    while old_next_cursor != next_cursor and next_cursor != 0
      old_next_cursor = next_cursor
      result = @@twitter.list_members(@list.username, @list.guid, {:cursor => next_cursor})  
      members = members + result["users"]
      next_cursor = result["next_cursor"]
      #puts "Member Count #{members.count} next cursor: #{next_cursor}"
    end
    members.each do |member|
      @list.members << {:username => member.screen_name, :id => member.id,
        :followers_count => member.followers_count,
        :friends_count => member.friends_count,
        :statuses_count => member.statuses_count}
    end
    @list.save!
  end
  
  
end