require 'rubygems'
require 'gnuplot'
require 'uri'
require 'csv'

PARTY = {}
CSV.open("tasks/politiker_parteien.csv", "r") do |row|
	PARTY[row[0]] = row[1]
end

cdu_people = []
spd_people = []
fdp_people = []
csu_people = []
linke_people = []
gruene_people = []
piraten_people = []

PARTY.each do |k,v|
  if v == "SPD"
    spd_people << k
  elsif v == "CDU"
    cdu_people << k
  elsif v == "FDP"
    fdp_people << k
  elsif v == "CSU"
    csu_people << k
  elsif v == "LINKE"
    linke_people << k
  elsif v == "GRUENEN"
    gruene_people << k
  elsif v == "PIRATEN"
    piraten_people << k
  end  
end

#cdu_words = ["cdu", "#cdu", "christlich", "demokratische", "union"]
#spd_words = ["spd", "#spd", "sozialdemokratische", "partei", "deutschlands"]
#fdp_words = ["fdp", "#fdp", "freie", "demokratische", "partei"]
#csu_words = ["csu", "#csu", "christlich-soziale", "union"]
#linke_words = ["linke", "#linke"]
#gruene_words = ["gruenen", "#gruenen", "grünen", "#grünen", "bündnis 90"]
#
#cdu_all = cdu_words + cdu_people
#spd_all = spd_words + spd_people
#fpd_all = fdp_words + fdp_people
#csu_all = csu_words + csu_people
#linke_all = linke_words + linke_people
#gruene_all = gruene_words + gruene_people
@umlauts = {
    '&#252;' => 'ü',
   '&#228;' => 'ä',
   '&#246;' => 'ö',
   '&#220;;' => 'Ü',
   '&#196;' => 'Ä',
   '&#214;' => 'Ö',
   '&#223;' => 'ß',
  }

all_parties = {"CDU" => cdu_people, "SPD" => spd_people, "FDP" => fdp_people,
               "CSU" => csu_people, "LINKE" => linke_people, "GRUENEN" => gruene_people, "PIRATEN" => piraten_people }

results = {}
all_parties.each do |k,v|
  puts "COMPUTING PARTY #{k}"
  all_parties.each do |ik,iv|
    word_count = 0
    puts "Comparing people from Party #{k} with Party #{ik}"
    v.each do |person|
      puts "#{person} from #{k}"
      candidate = Person.find_by_username(person)
      if candidate != nil
        entries = candidate.get_all_entries
        if entries != nil
          entries.each  do |entry|
            text = entry.text
            #Remove all uris from text
            URI.extract(text).each do |part|
              text= text.sub(part, "")
            end
            iv.each do |searchterm|
              #recode umlauts
              @umlauts.each_pair do |umlaut,entity|
                text.gsub!(umlaut,entity)            
              end
              text.downcase!              
              if text.include?(searchterm)
                 word_count += 1                 
              end                                
            end
          end
        end
      end
    end
    resultstring = k + "_" + ik
    results[resultstring] =  word_count
  end
end

outfile = File.open("word_count_export_incl_piraten.csv", 'wb')
CSV::Writer.generate(outfile) do |csv|
  results.each do |k,v|
    csv << [k,v]
  end
end
outfile.close

  