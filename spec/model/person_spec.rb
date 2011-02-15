require 'spec_helper'
require './spec/factories'


describe Person do
  
  it "should the correct person person given the id is provided" do
    project = Factory(:project)
    Person.collect_person(15533871, project.id, 10000)
    project.persons.first.username.should == "plotti"
  end
  
  it "should get the right amount of friend_ids for a person" do
    project = Factory(:project)
    Person.collect_person("plotti", project.id, 10000)
    project.persons.first.friends_ids.count.should be_close(110,10)
  end
  
  it "should collect the right amount of followers" do
    project = Factory(:project)
    Person.collect_person("plotti", project.id, 10000, "", true, true)
    project.persons.first.follower_ids.count.should be_close(136,10)
  end
  
  it "should save the category if i provide one" do
    project = Factory(:project)
    Person.collect_person("plotti", project.id, 10000, "testcategory", true, true)
    project.persons.first.category.should == "testcategory"
  end
  
  it "should collect the friends if want to " do
    project = Factory(:project)
    Person.collect_person_and_friends("plotti", project.id, 10000)
    project.persons.count.should be_close(116,10)
  end
  
  it "should collect my followers if I want to " do
    project = Factory(:project)
    Person.collect_person_and_followers("plotti", project.id, 10000)
    project.persons.count.should be_close(136,10)    
  end
  
end
