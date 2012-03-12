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
		puts "#{@@twitter.rate_limit_status.remaining_hits.to_s} calls left. Waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)		
	end	
	project.persons.each  do |person|
		Delayed::Job.enqueue(CollectListMembershipsJob.new(person.id, project.id))                
	end
	Rake::Task['collect_lists'].reenable
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
		puts "#{@@twitter.rate_limit_status.remaining_hits.to_s} calls left. Waiting for #{found_pending_jobs} Jobs to finish..."
		sleep(10)
	end
	lists = project.lists
	
	outfile = File.open("data/" + project.keyword + "_list.csv",'w')
	CSV::Writer.generate(outfile) do |csv|
		lists.each do |list|
			if list.name.include? project.keyword
				csv << [list.id]
				Delayed::Job.enqueue(CollectListMembersJob.new(list.id))
			end
		end
	end
	outfile.close
	Rake::Task['collect_memberships'].reenable
end

task :create_project_with_most_listed_persons do
	puts "CREATING PROJECT WITH MOST LISTED PERSONS"
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
				puts "Deleting job with more than #{job.attempts} attempts."
				job.delete				
			end
		end
		if found_pending_jobs == 0
			continue = false
		end
		puts "#{@@twitter.rate_limit_status.remaining_hits.to_s} calls left. Waiting for #{found_pending_jobs} Jobs to finish..."
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
	@@communities = ["music","blogger","socialmedia","entrepreneur","tech","marketing","writer","sports","fashion","photographer","design","politics","artist","news","media","celebrity","movies","technology","entertainment","gaming","webdesign","business","comedy","food","shopping","funny","fitness","geek","christian","education","creative","internetmarketing","student","books","advertising","realestate","mom","humor","film","author","graphicdesign","football","seo","writing","gamer","twitter","reading","actor","journalist","publicrelations","developer","videogames","producer","family","singer","radio","computers","green","apple","wine","beauty","science","hiphop","model","gay","money","life","finance","cars","songwriter","events","environment","soccer","inspiration","running","innovation","dogs","onlinemarketing","comics","consultant","wedding","cycling","golf","mac","actress","branding","speaker","rock","culture","jobs","programmer","spirituality","mobile","architecture","leadership","sustainability","beer","jewelry","dancing","software","theatre","conservative","guitar","party","communications","mother","animals","baseball","restaurant","coach","happy","television","pets","linux","startup","smallbusiness","publishing","illustrator","sales","charity","college","php","anime","travel","style","handmade","chicago","wordpress","rapper","gardening","gadgets","outdoors","history","reader","poetry","cinema","dance","crafts","poker","etsy","youtube","yoga","podcast"]
	#@@communities = ["entrepreneur","design","media","movies","entertainment","webdesign","business","shopping","funny","fitness","geek","christian","education","creative","books","mom","humor","film","author","seo","gamer","reading","journalist","developer","videogames","producer","family","singer","computers","green","apple","love","science","hiphop","gay","money","life","cars","songwriter","events","environment","soccer","inspiration","running","innovation","dogs","onlinemarketing","comics","consultant","wedding","cycling","mac","actress","branding","speaker","rock","culture","jobs","programmer","spirituality","mobile","leadership","beer","community","jewelry","software","theatre","conservative","guitar","party","communications","animals","baseball","restaurant","coach","happy","television","pets","linux","startup","smallbusiness","illustrator","sales","college","anime","style","handmade","chicago","wordpress","rapper","gardening","gadgets","outdoors","history","reader","poetry","cinema","crafts","poker","etsy","youtube","podcast"]
        #@@communities = ["Accountants","Actors","Advertising","Airlines","AlternativeHealth","Architects","Artists","Astrology","Astronomy","Automotive","Banking","Basketball","Beauty","Biking","Bloggers","CatLover","Celebrities","CEO","Charity","CloudComputing","CloudSecurity","CoffeeLovers","Comedy","CoolBrands","Dancers","Dating","Doctors","DogLovers","Engineer","ExtremeSports","Fashion","Fathers","Finance","Food","Football","Gamblers","Gaming","Giveaways","Golf","Gossip","Grammys","GraphicDesign","Healthcare","Hiking","HomeBusiness","Hospitality","IBM","Intel","Investors","Jobs","Lawyer","Marketing","MediaMoguls","Models","MommyBloggers","Mothers","Motocross","MovieGoers","Musicians","News","Oracle","Parents","Photography","Podcasters","Politics","PopMusic","Publishing","Radio","RealEstate","Religion","Reporter","RoyalWedding","Sailing","Shopaholics","Socialmedia","Sport","Students","Surfing","Sustainability","Tech","Tennis","Trading","Travel","VIPMommies","Vloggers","WallSt","Weightlifting","WineLover"]
		@@communities.each do |community|
		ENV["keyword"] = community
		Rake::Task['collect_community'].invoke
	end
end
