#!/usr/bin/env ruby

#sources = [18477798, 46853131, 16850725, 46778529, 19248117, 47005158, 47402649, 25544152, 46336756, 45628882, 21481343, 47033840, 13965312, 18657360, 35067843, 19173787, 42202453, 47496920, 30825667, 16710435, 18276451, 20992556, 2180371, 15896379, 18014005, 6029522, 17682351, 18288555, 24532616, 17092902]

sources = []
Project.find(4).persons.each do |person|
  sources << person.twitter_id
end

counter = {}
i = 0
require 'csv'

outfile = File.open("new_sources_count.csv",'w')

  CSV::Writer.generate(outfile) do |csv|
    Project.find(4).persons.all.each do |person|
      i += 1
      puts i
      counter[person] = 0
      sources.each do |source|
        if person.friends_ids.include?(source)
          counter[person] = counter[person] +1
        end
      end
    csv << [person.username, counter[person]]
    end
  end
  
outfile.close
