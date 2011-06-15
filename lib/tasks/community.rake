require 'config/environment'

#usage rake keyword=ruby collect_community

@@ID = nil

task :new_project  do 
	project = Project.new(:name => ENV["keyword"]+"lists", :keyword => ENV["keyword"])
	project.save!
	@@ID = project.id
end

task :add_seed_people do 
	puts "ADDING SEED PEOPLE "
	project = Project.find(@@ID)
	#Collect 4 pages a 25 people = 100 people
	project.add_people_from_wefollow(4)
end

task :collect_lists do
	puts "COLLECTING LISTS"
	project = Project.find(@@ID)
	continue = true
	while continue		
		found_pending_jobs = 0				
		Delayed::Job.all.each do |job|			
			if job.handler.include? "CollectPersonJob"
				found_pending_jobs += 1
			end
			if job.attempts >= 4
				puts "Deleting job with more than #{job.attempts} attempts."
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts "waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)		
	end	
	project.persons.each  do |person|
		Delayed::Job.enqueue(CollectListMembershipsJob.new(person.id, project.id))                
	end
end

task :collect_memberships do
	puts "COLLECTING MEMBERSHIPS OF LISTS"
	project = Project.find(@@ID)
	continue = true
	while continue
		found_pending_jobs = 0
		Delayed::Job.all.each do |job|			
			if job.handler.include? "CollectListMembershipsJob"
				found_pending_jobs += 1
			end
			if job.attempts >= 4
				puts "Deleting job with more than #{job.attempts} attempts."
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts "waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)
	end
	lists = project.lists
	
	outfile = File.open(project.keyword + "_list.csv",'w')
	CSV::Writer.generate(outfile) do |csv|
		lists.each do |list|
			if list.name.include? project.keyword
				csv << [list.id]
				Delayed::Job.enqueue(CollectListMembersJob.new(list.id))
			end
		end
	end
	outfile.close
end

task :create_project_with_most_listed_persons do
	puts "CREATING PROJECT WITH MOST LISTED PERSONS"
	project = Project.find(@@ID)
	continue = true
	while continue
		found_pending_jobs = 0
		Delayed::Job.all.each do |job|			
			if job.handler.include? "CollectListMembersJob"
				found_pending_jobs += 1
			end
			if job.attempts >= 4
				puts "Deleting job with more than #{job.attempts} attempts."
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts "waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)
	end
	persons = project.generate_new_project_from_most_listed_members
	new_project = Project.new(:name => ENV["keyword"], :keyword => ENV["keyword"])
	new_project.save!
	maxfriends = 10000
	category = ""
	persons[0..99].each do |person|		
		Delayed::Job.enqueue(CollectPersonJob.new(person[:username],new_project.id,maxfriends,category))  	
	end	
end

task :collect_community => [:new_project,:add_seed_people,:collect_lists,:collect_memberships,:create_project_with_most_listed_persons] do
	jobs = Delayed::Job.count
	puts "Enqueued all necessary tasks. Please wait for remaining #{jobs} jobs to finish"
end