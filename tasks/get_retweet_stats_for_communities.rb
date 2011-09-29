##############################
# Generate RT Matrix
#############################

projects = [2,4,7,9,14]

results = {}

projects.each do |project|  
    puts "Project #{project}"
    result = {}    
    projects.each do |tmp_project|
        result[Project.find(tmp_project).name] = 0
        result["outside"] = 0
        project_persons = Project.find(tmp_project).persons.collect{|p| p.username}        
        Project.find(project).persons.each do |person|
            person.feed_entries.each do |feed|
                feed.retweet_ids.each do |retweet|               
                    if project_persons.include?(retweet[:person])
                        result[Project.find(tmp_project).name] +=  1
                    else
                        result["outside"] += 1
                    end
                end        
            end
        end
    end
    results[Project.find(project).name] = result
    puts result
end

##############################
# Generate FF Matrix
##############################


projects = [1]

results = {}

projects.each do |project|  
    puts "Project #{project}"
    result = {}    
    projects.each do |tmp_project|
        result[Project.find(tmp_project).name] = 0
        result["outside"] = 0
        project_persons = Project.find(tmp_project).persons.collect{|p| p.twitter_id}
        Project.find(project).persons.each do |person|
            person.friends_ids.each do |id|                
                    if project_persons.include?(id)
                        result[Project.find(tmp_project).name] +=  1
                    else
                        result["outside"] += 1
                    end
            end                    
        end
    end
    results[Project.find(project).name] = result
    puts result
end

##############################
# Generate Outside AT Matrix
##############################

projects = [2,4,7,9,14]

results = {}

project_persons = []
projects.each do |tmp_project|
    project_persons += Project.find(tmp_project).persons.collect{|p| p.username}        
end
projects.each do |project|
    project = Project.find(project)
    puts "Project #{project}"
    result = {}
    result["outside"] = 0
    result[Project.find(project).name] = 0    
    project.persons.each do |person|
        puts person.name
        person.feed_entries.each do |tweet|                
            found = false
            project_persons.each do |tmp_user|                    
                if tweet.text.include?("@" + tmp_user + " ") && tweet.retweet_ids == []
                    found = true
                    result[project.name] +=  1                            
                end                        
            end
            if found == false
                result["outside"] += 1
            end                                        
        end
    end
    results[project.name] = result
    puts result
end
