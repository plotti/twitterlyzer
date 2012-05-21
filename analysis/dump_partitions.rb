require '../config/environment'
require 'faster_csv'

#Log 04.04 Dumping first networks
@@communities = [4, 6, 9, 13, 17, 19, 21, 25, 27, 31, 33, 39, 44, 46, 48, 56, 62, 70, 72, 82, 86, 94, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]

#Log 05.05 Dumping more networks
@@communities += [112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 137, 141, 143, 145, 149, 153, 155, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 170, 171, 172, 174, 175, 176, 177, 178, 179, 180, 181, 187, 189, 207, 209, 211, 213, 217, 219, 221, 233, 245, 247, 251, 253, 255, 257, 259, 261, 263, 265, 271, 275, 279, 281, 285, 291, 293, 297, 303, 305, 307, 311, 315, 317, 319]
#323 segfault
@@communities += [325, 327, 329, 333, 337, 339, 341, 351, 353, 355, 357, 359, 361, 365, 367, 369, 371, 373, 379, 385, 387, 389, 391, 395, 397, 399, 401, 403, 405, 407]

outfile = File.open("data/partitions.csv", "w+")

sorted_members ={}
@@communities.each do |community|  
  project = Project.find(community)
  puts "Reading in project #{project.name}"
  sorted_members[project.name] = FasterCSV.read("#{RAILS_ROOT}/data/#{project.name}_sorted_members.csv")
end

CSV::Writer.generate(outfile) do |csv|
  seen_persons = []
  @@communities.each do |community|
    project = Project.find(community)    
    puts "Working on project id: #{community}"
    project.persons.each do |person|
      if !seen_persons.include? person.username 
        list_count = 0
        membership = ""
        memberships = []
        sorted_members.each do |key,list|          
          list.each do |member|
            begin
              if member[0].downcase == person.username.downcase
                if member[2].to_i > list_count
                  membership = key
                  list_count = member[2].to_i
                  memberships += [membership,list_count]
                end            
              end
            rescue
              puts "Found a problem for project #{key} Member: #{member[0]} or person #{person.username}"
            end                        
          end
        end
        seen_persons << person.username
        csv << [person.username, membership, list_count, memberships.count, memberships.join(",")]
      end      
    end
  end
end