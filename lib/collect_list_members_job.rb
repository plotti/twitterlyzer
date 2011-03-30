#!/usr/bin/env ruby
class CollectListMembersJob < Struct.new(:id)
  def perform
    List.collect_list_members(id)
  end
end
