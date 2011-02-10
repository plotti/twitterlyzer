require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < ActiveSupport::TestCase
  
  def setup
    @project = Project.create! :name => "Testproject", :description => "Testdescription", :monitor_feeds => true
  end
  
  def teardown
    @project = nil
  end
  
  def test_should_collect_person
    Person.delete_all
    person = Person.collect_person "plotti", @project.id, 10000000   
    assert_equal person.username, "plotti", "Persons Username should match"    
    flunk("Friends Ids should not be empty") if person.friends_ids == []    
  end
  
  def test_should_collect_friends
    Person.delete_all
    person = Person.twitter_user(:params => {:id => "plotti"})      
    person = Person.add_entry(person)    
    person.collect_friends(person.twitter_id)
    flunk("Collect Friends should not be empty") if person.friends_ids == []
  end
  
  def test_should_collect_followers
    Person.delete_all
    person = Person.twitter_user(:params => {:id => "plotti"})      
    person = Person.add_entry(person)
    person.collect_followers(person.twitter_id)
    flunk("Collect Followers should not be empty") if person.follower_ids == []
  end
  
  def test_should_collect_person_and_friends
    Person.delete_all
    Person.collect_person_and_friends("plotti",@project.id,10000000)
    flunk("Collect Person and friends should not be empty") if @project.persons.count < 50 
  end
  
  def test_should_collect_person_and_followers
    Person.delete_all
    Person.collect_person_and_followers("plotti",@project.id,10000000)
    flunk("Collect Person and followers should not be empty") if @project.persons.count < 10
  end
  
  def test_friends_ids
    Person.delete_all
    person = Person.collect_person "plotti", @project.id,10000000
    flunk("Friends Ids should not be empty") if person.friends_ids == []   
  end
  
  def test_follower_ids
    Person.delete_all
    person = Person.collect_person "plotti", @project.id, 10000000, false, true 
    flunk("Friends Ids should not be empty") if person.follower_ids == []   
  end
  
  def test_get_all_friends
    Person.delete_all
    person = Person.collect_person_and_friends("plotti",@project.id,10000000)    
    flunk("Person get friends should not be empty") if person.get_all_friends == []     
  end
  
  def test_get_all_followers
    Person.delete_all
    person = Person.collect_person_and_followers("plotti",@project.id,10000000)
    flunk("Person get friends should not be empty") if person.get_all_followers == []         
  end
  
  def test_should_update_twitter_stats
    Person.delete_all
    person = Person.collect_person "plotti", @project.id, 10000000   
    Person.update_twitter_stats(person.twitter_id)    
  end
end
