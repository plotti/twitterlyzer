class CollectPersonsAndFeedsJob < Struct.new(:id, :project_id)
  def perform
    puts "Collecting person and feeds for result: " +  id.to_s
    SearchResult.collect(id, project_id)    
  end
end