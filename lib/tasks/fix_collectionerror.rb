require 'config/environment'

#@@communities = ["geography","columnist","linguistics","literacy","alternativehealth","dental","veteran","smartphone","seniors","html","diversity","sculpture","poverty","archaeology","database","neuroscience","army","filmfestival","sociology","chemistry","housing","justice","drums","ecology","mathematics","anthropology","collectibles","magician","drama","hacking","biology","marriage","nursing","mobilephones","activism","climbing","ipad","pharma","reporter","storage","physics","pregnancy","democrat","classicalmusic","banking","hollywood","homeschool","dining","genealogy","agriculture","piano","buddhism","realitytv","mentalhealth","toys","climatechange","documentary","islam","employment","boating","hunting","cancer","fantasy","gambling","theater","liberal","multimedia","jewish","romance","teaching","jokes","weather","engineering","legal","baking","newspaper","attorney","rugby","aviation","wrestling","composer","electronicmusic","greenliving","meditation","highered","peace","horror","philanthropy","racing","chef","screenwriter","humanrights","insurance","jazz","career","military","school","drinking","energy","father","painting","exercise","flash","construction","university","tvshows","motorcycle","vegetarian","skiing","recipes","opensource","animation","skateboarding","lesbian","medicine","management","director","nature","swimming","economics","magazine","children","fishing","weightloss","psychology","literature","hockey","philosophy","nutrition","parenting","blogs","iphone","cooking","beauty","wine","singer","developer","publicrelations","actor","writing","author","fitness","funny","shopping","gaming","fashion"]

@@communities = [115]
@@communities.each do |community|

  puts "Working on #{community}"
  
  #begin
    #Get the new members
    project = Project.find(community)
    project_lists = Project.find_by_name(project.name+"lists")
    persons = project_lists.generate_most_listed_members
    
    #old_usernames = project.persons.collect{|p| p.username}
    #new_usernames = persons[0..100].collect{|p| p[:username]}
    
    #overlap = old_usernames & new_usernames
    #puts "For project #{community} we have an overlap of #{overlap.count.to_f/100}"
  
  #rescue
    puts "something went wrong"
  #end
  
  #Delete the old members
  #project = Project.find_by_name(community)
  #project.persons.delete
  #project.save!

  #maxfriends = 10000
  #category = ""
  #size = 100 #default  
  #persons[0..size].each do |person|		
  #        Delayed::Job.enqueue(CollectPersonJob.new(person[:username],project.id,maxfriends,category))  	
  #end

end

