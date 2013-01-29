require '../config/environment'
require 'faster_csv'

search = FeedEntry.search do
    fulltext "maiziere"
    paginate :page => 1, :per_page => 100000
end

r = []
search.results.each do |result|
    r << result 
end


outfile = File.open("#{RAILS_ROOT}/panetta.csv","w")
CSV::Writer.generate(outfile) do |csv|
    csv << ["Author", "Retweet IDs count", "Text", "Published At", "URL", "Favorited?", "In reply to"]
    s.each do |result|
        csv << [result.author, result.retweet_ids.count, result.text, result.published_at, result.url, result.favorited, result.reply_to]
    end
end
outfile.close

s =[]
search.results.each do |result|
    if result.retweet_ids.count > 0
        s << result 
    end
end
