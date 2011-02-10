class CollectAllProjectEntriesJob < Struct.new(:project_id)
  def perform
    project = Project.find(project_id)
    persons = project.persons

    puts "Analyzing " + project.name.to_s  + " with " + persons.count.to_s + " persons."
        
    persons.each do |person|
      puts "Collected " + FeedEntry.collect_all_entries(person).to_s + " feeds of of: " + person.username
    end
  end
end
