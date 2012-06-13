require '../config/environment'
require 'faster_csv'

# Deprecated: This file was used to re-import the people that were listed on the old sorted_member lists from the old system
#First reimport of old listings
#groups_for_import = ["musician","tech","marketing","sport","fashion","photography","politics","news","gaming","comedy","food","advertising","realestate","football","actor","radio","wine","beauty","finance","golf","sustainability","publishing","charity"]

groups_for_import = ["accounting", "airlines", "astrology", "astronomy", "automotive", "basketball", "ceo", "dating", "healthcare", "hiking", "hospitality", "ibm", "intel", "investor", "java", "lawyer", "oracle", "perl", "python", "religion", "ruby", "sailing", "surfing", "tennis", "trading"]
groups_for_import.each do |group|
  sorted_members  = FasterCSV.read("#{RAILS_ROOT}/data/old_lists/#{group}_sorted_members.csv")
  i = 0
  puts "Working on Group: #{group}"
  
  puts "Creating project with keyword #{group}."
  new_project = Project.new(:name => group, :keyword => group)
  maxfriends = 10000
  category = ""
  new_project.save!
  
  sorted_members.each do |member|
    i += 1
    if i < 102
      #puts "Enqueing Job for #{i}member #{member[0]} with #{member[2]} listings."  
      Delayed::Job.enqueue(CollectPersonJob.new(member[0],new_project.id,maxfriends,category))
    end        
  end
end
