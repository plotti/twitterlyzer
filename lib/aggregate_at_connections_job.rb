class AggregateAtConnectionsJob < Struct.new(:person_id, :projectid, :usernames)
  def perform    
    Project.find_delayed_at_connections_for_person_and_project(person_id,projectid, usernames)
  end
end