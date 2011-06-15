require 'spec_helper'
require './spec/factories'

describe Project do
  
  it "should contain 4 plottis with their connections" do
    project = Factory(:project)
    Person.collect_person("plotti1", project.id, 10000)
    Person.collect_person("plotti2", project.id, 10000)
    Person.collect_person("plotti3", project.id, 10000)
    Person.collect_person("plotti4", project.id, 10000)
    project.persons.count.should == 4
  end
  
  it "should obtain all the FF connections" do
    project = Factory(:project)
    Person.collect_person("plotti1", project.id, 10000)
    Person.collect_person("plotti2", project.id, 10000)
    Person.collect_person("plotti3", project.id, 10000)
    Person.collect_person("plotti4", project.id, 10000)
    result = project.find_all_connections
    puts result.to_yaml
    result.include?(["plotti2","plotti1"]).should == true
    result.include?(["plotti3","plotti1"]).should == true
    result.include?(["plotti4","plotti3"]).should == true
    result.include?(["plotti3","plotti4"]).should == true
    result.include?(["plotti1","plotti4"]).should == true
  end
  
  it "should contain all the @ mentions" do
    project = Factory(:project)
    Person.collect_person("plotti1", project.id, 10000)
    Person.collect_person("plotti2", project.id, 10000)
    Person.collect_person("plotti3", project.id, 10000)
    Person.collect_person("plotti4", project.id, 10000)    
    project.persons.each do |p|
      FeedEntry.collect_all_entries p
    end
    project.persons.each do |p|
      p.feed_entries.each do |f|
        FeedEntry.collect_retweet_ids_for_entry(f)
      end
    end
    result = project.find_all_valued_connections
    puts result
    result.include?(["plotti2","plotti1",1]).should == true
    result.include?(["plotti3","plotti1",2]).should == true
    result.include?(["plotti1","plotti4",1]).should == true
  end
  
  it "should contain the RT connections" do
        project = Factory(:project)
    Person.collect_person("plotti1", project.id, 10000)
    Person.collect_person("plotti2", project.id, 10000)
    Person.collect_person("plotti3", project.id, 10000)
    Person.collect_person("plotti4", project.id, 10000)    
    project.persons.each do |p|
      FeedEntry.collect_all_entries p
    end
    project.persons.each do |p|
      p.feed_entries.each do |f|
        FeedEntry.collect_retweet_ids_for_entry(f)
      end
    end
    result = project.find_all_retweet_connections
    puts result
    result.include?(["plotti2","plotti1",1]).should == true
    result.include?(["plotti4","plotti3",2]).should == true
    result.include?(["plotti3","plotti4",1]).should == true
  end
  
  
end
