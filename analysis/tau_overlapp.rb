#Compute Kendalls Tau
require '../config/environment'
require 'statsample'

communities = ["java", "astronomy", "marketing", "surfing", "hospitality", "finance", "tennis", "tech", "trading", "astrology", "politics", "news", "perl", "sailing", "photography", "lawyer", "hiking", "basketball", "sustainability", "python", "investor", "advertising", "sport", "football", "religion", "airlines", "dating", "ruby", "automotive", "comedy", "healthcare", "ceo", "food", "accounting", "golf", "musician", "realestate", "radio"]
outfile = File.open("#{RAILS_ROOT}/analysis/results/stats/#{584}_tau_stats.csv",'w')

CSV::Writer.generate(outfile) do |csv|
  csv << ["Name", "Spearmans_rho", "Kendalls_tau", "percent_found_in_200"]
  communities.each do |community|
      
    i = 0
    sorted_members_a = []    
    FasterCSV.foreach("#{RAILS_ROOT}/data/#{community}_sorted_members.csv") do |row|    
      sorted_members_a << row if i > 0
      i += 1
      break if i == 100
    end
    sorted_members_a.collect!{|m| m[0]}
    
    i = 0
    sorted_members_b = []    
    FasterCSV.foreach("#{RAILS_ROOT}/../Dropbox/phD/data/#{community}_sorted_members.csv") do |row|    
      sorted_members_b << row if i > 0
      i += 1
      break if i == 200
    end
    sorted_members_b.collect!{|m| m[0]}
      
      
    a = []
    b = []
    i = 0
    sorted_members_a.each do |member|
      a << i
      b << sorted_members_b.index(member)
      i += 1
    end
  
    csv << [community, Statsample::Bivariate.spearman(a.to_scale,b.to_scale), Statsample::Bivariate.tau_a(a.to_scale,b.to_scale), b.compact.count/b.count.to_f]
    
  end
end