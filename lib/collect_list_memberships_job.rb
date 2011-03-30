#!/usr/bin/env ruby
class CollectListMembershipsJob < Struct.new(:id, :project_id)
  def perform
    person = Person.find(id)
    Person.collect_list_memberships(person.username,project_id)
  end
end
