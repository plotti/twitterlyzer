module PeopleHelper
  
  def render_followers_link(person,project_id)
    collected_followers = person.get_all_followers.length
    result = ""
    if collected_followers > 0
        result += link_to "Show collected Followers(" + collected_followers.to_s + ") <br> ",
                  :action => "followers",
                  :id => person.id,
                  :project_id => project_id
    end      
    result+= link_to_remote 'Collect all Followers (' + person.followers_count.to_s + ")",
            :url => {:controller => 'people', :action=>'collect_all_followers', :id => person.id, :project_id => project_id},
            :confirm => 'This operation might take a long time. Are you sure?',
            :loading => "Element.show('spinner')",
            :complete => "Element.hide('spinner')"
    return result
  end
  
  def render_friends_link(person,project_id)                        
    collected_friends = person.get_all_friends.length
    result = ""
    if  collected_friends > 0
      result += link_to "Show collected friends(" + collected_friends.to_s + ") <br> ",
                url_for => {:controller => 'people',
                        :action => "friends",
                        :id => person.id,
                        :project_id => project_id}
    end    
    result += link_to_remote 'Collect all friends (' + person.friends_count.to_s + ")",
              :url => {:controller => 'people', :action=>'collect_all_friends', :id => person.id, :project_id => project_id},
              :confirm => 'This operation might take a long time. Are you sure?',
              :loading => "Element.show('spinner')",
              :complete => "Element.hide('spinner')"      
  end
  
  def render_updates_link(person,project_id)
    collected_updates = person.get_all_entries.length
    result = ""
    if collected_updates > 0  
      result += link_to 'Show collected Feeds(' + collected_updates.to_s + ") <br>",
                project_person_feed_entries_path(project_id,person)
    end
    result += link_to_remote 'Collect all Entries(' + person.statuses_count.to_s + ")", 
              :url => {:controller => 'feed_entries', :action=>'collect_all_entries', :id => person.id, :project_id => project_id},
              :confirm => 'This operation might take a long time. Are you sure?',
              :loading => "Element.show('spinner')",
              :complete => "Element.hide('spinner')"
  end

end
