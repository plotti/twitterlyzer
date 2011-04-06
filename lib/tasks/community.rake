require 'config/environment'

@@ID = nil

task :new_project  do 
	project = Project.new(:name => ENV["keyword"], :keyword => ENV["keyword"])
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
	lists.each do |list|
		if list.name.include? project.keyword      
			Delayed::Job.enqueue(CollectListMembersJob.new(list.id))
		end
	end
end

task :collect_community => [:new_project,:add_seed_people,:collect_lists,:collect_memberships] do
	puts "Enqueued all necessary tasks. Please wait for jobs to finish"
end