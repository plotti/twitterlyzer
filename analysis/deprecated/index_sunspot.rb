i = 0
FeedEntry.find_in_batches(:batch_size => 500) do |batch|    
    begin
        i += 1
        Sunspot.index!(batch)
        if i % 1000 == 0
            puts "#{i} #{batch.id}"
        end
    rescue Timeout::Error => e
        t = Time.now 
        puts "Timeout from Solr at: #{t}"
    end
end