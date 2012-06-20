class AggregateRtConnectionsJob < Struct.new(:person_id, :project_id, :usernames)
  def perform    
    Project.find_delayed_retweet_connections_for_person(person_id, project_id, usernames)
  end
end