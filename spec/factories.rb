require 'rubygems'
require 'factory_girl'

Factory.define :person do |p|
  p.name  "Joe Nuxoll"
  p.category  "Java"
  p.acc_created_at  "2007-04-05"
  p.last_activity   "2011-02-10"
  p.twitter_id  "3557831"
  p.statuses_count  "3595"
  p.username  "joeracer"
end
