require 'config/environment'

#usage rake keyword=ruby collect_community
#usage rake project_id=2 keyword="some name for the project" re_collect_community #if you want to start over with a set of already collected people
#usage rake collect_communities #to collect a number of communities defined in the array below for further processing

@@ID = nil
@@log = Logger.new("log/community.log")

task :new_project  do 
	project = Project.new(:name => ENV["keyword"]+"lists", :keyword => ENV["keyword"])
	project.save!
	@@ID = project.id
	Rake::Task['new_project'].reenable
end

task :find_project do
	@@ID = ENV["project_id"]
end


task :add_seed_people do 
	puts "ADDING SEED PEOPLE of #{ENV['keyword']}"
	project = Project.find(@@ID)
	
	# Strategy A) Get people from wefollow
	# Collect 4 pages a 25 people = 100 people
	# puts "Using wefollow people for seed"
	# project.add_people_from_wefollow(4)
	
	# Strategy B) Take the people we already collected in the last run
	puts "Using Exisiting people for seed"
	tmp_project = Project.find_by_name(ENV['keyword'].to_s)
	tmp_project.persons.each do |person|
		project.persons << person
	end
	project.save!
	Rake::Task['add_seed_people'].reenable
end

task :collect_lists do
	@@log.info("Started List collection at #{Time.now} for project_id: #{ENV["project_id"]}")
	puts "COLLECTING LISTS of #{ENV['keyword']}"
	project = Project.find(@@ID)
	continue = true
	while continue		
		found_pending_jobs = 0				
		Delayed::Job.all.each do |job|			
			if job.handler.include? "CollectPersonJob"
				found_pending_jobs += 1
			end
			if job.attempts >= 4				
				puts"CL: #{Project.get_remaining_hits} calls left. Deleting job with more than #{job.attempts} attempts."		
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts"CL: #{Project.get_remaining_hits} calls left. Waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)		
	end	
	project.persons.each  do |person|
		Delayed::Job.enqueue(CollectListMembershipsJob.new(person.id, project.id))                
	end
	Rake::Task['collect_lists'].reenable
end

task :collect_memberships do
	@@log.info("Started List membership collection at #{Time.now} for project: #{ENV['keyword']}")
	puts "COLLECTING MEMBERSHIPS OF LISTS of #{ENV['keyword']}"
	project = Project.find(@@ID)
	continue = true
	while continue
		found_pending_jobs = 0
		Delayed::Job.all.each do |job|			
			if job.handler.include? "CollectListMembershipsJob"
				found_pending_jobs += 1
			end
			if job.attempts >= 4
				puts"CM: #{Project.get_remaining_hits} calls left. Deleting job with more than #{job.attempts} attempts."
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts"CM: #{Project.get_remaining_hits} calls left. Waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)
	end
	lists = project.lists
	
	outfile = File.open("data/" + project.keyword + "_list.csv",'w')
	CSV::Writer.generate(outfile) do |csv|
		lists.each do |list|
			begin
				members = list.members.count
			rescue
				members = 0
			end
			csv << [list.id,list.uri,members]
			if list.name.include? project.keyword				
				Delayed::Job.enqueue(CollectListMembersJob.new(list.id))
			end
		end
	end
	outfile.close
	Rake::Task['collect_memberships'].reenable
end

task :create_project_with_most_listed_persons do
	@@log.info("Started creation of Project at #{Time.now} for project_id: #{ENV['keyword']}")
	puts "CREATING PROJECT WITH MOST LISTED PERSONS of #{ENV['keyword']}"
	if ENV["id"] == nil
		project = Project.find(@@ID)
	else
		project = Project.find(ENV["id"])
	end	
	continue = true
	while continue
		found_pending_jobs = 0
		Delayed::Job.all.each do |job|			
			if job.handler.include? "CollectListMembersJob"
				found_pending_jobs += 1
			end
			if job.attempts >= 4
				puts"CP: #{Project.get_remaining_hits} calls left. Deleting job with more than #{job.attempts} attempts."
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts"CP: #{Project.get_remaining_hits} calls left. Waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)
	end
	persons = project.generate_most_listed_members
	new_project = Project.new(:name => ENV["keyword"], :keyword => ENV["keyword"])
	new_project.save!
	maxfriends = 10000
	category = ""
	if ENV["size"] == nil
		size = 100 #default
	else
		size = ENV["size"].to_i	
	end	
	persons[0..size].each do |person|		
		Delayed::Job.enqueue(CollectPersonJob.new(person[:username],new_project.id,maxfriends,category))  	
	end
	Rake::Task['create_project_with_most_listed_persons'].reenable
end

task :collect_community => [:new_project,:add_seed_people,:collect_lists,:collect_memberships,:create_project_with_most_listed_persons] do
	jobs = Delayed::Job.count
	puts "Enqueued all necessary tasks. Please wait for remaining #{jobs} jobs to finish"
	Rake::Task['collect_community'].reenable
end

task :re_collect_community => [:find_project, :collect_lists, :collect_memberships,:create_project_with_most_listed_persons] do
	jubs = Delayed::Job.count
	puts "Enqueued all necessary tasks. Please wait for remaining #{jobs} jobs to finish"
end

# VERY IMPORTANT
# After that the diffusions should be collected. (see diffusion.rake)
# AFTER THIS PROCESS THE CHOSEN COMMUNITY IDs HAVE TO BE ADDED TO CONFIG/INITIALIZERS/TWITTERLYZER communities.

task :collect_communities do
	# Type in some keywords that you like to collect communities for
	# e.g. @@communities = ["java", "astronomy", "surfing"]
	@@communities.each do |community|
		ENV["keyword"] = community
		Rake::Task['collect_community'].invoke
	end
end
