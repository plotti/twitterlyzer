class AggregateAtConnectionsJob < Struct.new(:person_id, :projectid)
  def perform    
    Project.find_at_connections_for_person_and_project(person_id,projectid)
  end
end