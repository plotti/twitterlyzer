require 'config/environment'

#usage rake keyword=ruby collect_community
#usage rake project_id=2 keyword="some name for the project" re_collect_community #if you want to start over with a set of already collected people
#usage rake collect_communities #to collect a number of communities defined in the array below for further processing

@@ID = nil

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
	#Collect 4 pages a 25 people = 100 people
	project.add_people_from_wefollow(4)
	Rake::Task['add_seed_people'].reenable
end

task :collect_lists do
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
			if list.name.include? project.keyword
				csv << [list.id,list.name]
				Delayed::Job.enqueue(CollectListMembersJob.new(list.id))
			end
		end
	end
	outfile.close
	Rake::Task['collect_memberships'].reenable
end

task :create_project_with_most_listed_persons do
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
	persons = project.generate_new_project_from_most_listed_members
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

task :collect_communities do
	#Communities in Reverse Order
	# Log:
	# Skipped "travel" when computing biggest community
	# Removed a couple of communities that I have collected before (see phd/analysis/groups/lists)
	@@communities = ["leadership", "architecture", "mobile", "spirituality", "programmer", "jobs", "culture", "rock", "speaker", "branding", "actress", "mac", "cycling", "wedding", "consultant", "comics", "dogs", "innovation", "running", "inspiration", "soccer", "environment", "events", "songwriter", "cars", "life", "money", "gay", "model", "hiphop", "science", "apple", "green", "computers", "singer", "family", "producer", "videogames", "developer", "publicrelations", "journalist", "reading", "gamer", "writing", "seo", "graphicdesign", "author", "film", "humor", "mom", "books", "student", "internetmarketing", "creative", "education", "christian", "geek", "fitness", "funny", "shopping", "business", "webdesign", "entertainment", "movies", "celebrity", "media", "artist", "design", "writer", "entrepreneur", "socialmedia", "blogger"]	
	#@@communities = ["podcast", "yoga", "youtube", "etsy", "poker", "crafts", "dance", "cinema", "poetry", "reader", "history", "outdoors", "gadgets", "gardening", "rapper", "wordpress", "chicago", "handmade", "style", "travel", "anime", "php", "college", "charity", "sales", "illustrator", "publishing", "smallbusiness", "startup", "linux", "pets", "television", "happy", "coach", "restaurant", "baseball", "animals", "mother", "communications", "party", "guitar", "conservative", "theatre", "software", "dancing", "jewelry", "beer", "sustainability", "leadership", "architecture", "mobile", "spirituality", "programmer", "jobs", "culture", "rock", "speaker", "branding", "actress", "mac", "golf", "cycling", "wedding", "consultant", "comics", "onlinemarketing", "dogs", "innovation", "running", "inspiration", "soccer", "environment", "events", "songwriter", "cars", "finance", "life", "money", "gay", "model", "hiphop", "science", "beauty", "wine", "apple", "green", "computers", "radio", "singer", "family", "producer", "videogames", "developer", "publicrelations", "journalist", "actor", "reading", "gamer", "writing", "seo", "football", "graphicdesign", "author", "film", "humor", "mom", "realestate", "advertising", "books", "student", "internetmarketing", "creative", "education", "christian", "geek", "fitness", "funny", "shopping", "food", "comedy", "business", "webdesign", "gaming", "entertainment", "technology", "movies", "celebrity", "media", "news", "artist", "politics", "design", "photographer", "fashion", "sports", "writer", "marketing", "tech", "entrepreneur", "socialmedia", "blogger", "music"]	
	#Communities in Normal Order
	#@@communities = ["music","blogger","socialmedia","entrepreneur","tech","marketing","writer","sports","fashion","photographer","design","politics","artist","news","media","celebrity","movies","technology","entertainment","gaming","webdesign","business","comedy","food","shopping","funny","fitness","geek","christian","education","creative","internetmarketing","student","books","advertising","realestate","mom","humor","film","author","graphicdesign","football","seo","writing","gamer","twitter","reading","actor","journalist","publicrelations","developer","videogames","producer","family","singer","radio","computers","green","apple","wine","beauty","science","hiphop","model","gay","money","life","finance","cars","songwriter","events","environment","soccer","inspiration","running","innovation","dogs","onlinemarketing","comics","consultant","wedding","cycling","golf","mac","actress","branding","speaker","rock","culture","jobs","programmer","spirituality","mobile","architecture","leadership","sustainability","beer","jewelry","dancing","software","theatre","conservative","guitar","party","communications","mother","animals","baseball","restaurant","coach","happy","television","pets","linux","startup","smallbusiness","publishing","illustrator","sales","charity","college","php","anime","travel","style","handmade","chicago","wordpress","rapper","gardening","gadgets","outdoors","history","reader","poetry","cinema","dance","crafts","poker","etsy","youtube","yoga","podcast"]	
	@@communities.each do |community|
		ENV["keyword"] = community
		Rake::Task['collect_community'].invoke
	end
end
