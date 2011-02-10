class TwoStepEgonetJob < Struct.new(:id, :project_id)
  def perform
    start_person = Person.find(id)    
    first_step_followers = Person.collect_all_friends(start_person,project_id)
    print "1st Step followers: " + first_step_followers.count.to_s 
    i = 0
    first_step_followers.each do |follower|
      i = i + 1
      print "Collecting " + follower.friends_count.to_s + " friends of: " +  follower.username + " (" + i.to_s + "/" + first_step_followers.count.to_s + ")"
      Person.collect_all_friends(follower,project_id)
    end
  end
end