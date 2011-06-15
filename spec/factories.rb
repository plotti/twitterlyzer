require 'rubygems'
require 'factory_girl'

Factory.define :project do |p|
  p.name  "Test project"
  p.keyword "plotti"
end

Factory.define :person do |p|
  p.name  "Joe Nuxoll"
  p.category  "Java"
  p.acc_created_at  "2007-04-05"
  p.last_activity   "2011-02-10"
  p.twitter_id  "3557831"
  p.statuses_count  "3595"
  p.username  "joeracer"
  p.project {[Factory(:project)]}
end

Factory.define :feed_entry do |f|
  f.text "Collection of Data Analysis Books http://www.downeu.com/dl/Statistical+Methods+For+Spatial+Data+Analysis.html"
  f.guid 15312085189
  f.retweet_count 6
  f.person {Factory(:person)}
end

Factory.define :list do |l|
  l.username "plotti4"
  l.name "list-listing-plotti1"
  l.slug "plotti4/list-listing-plotti1"
end
