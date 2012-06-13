#!/usr/bin/env ruby
def alnorm(x, upper = true)
  # Local variables
  con = 1.28 ; fn_val = 0.0

  # Machine dependent constants
  # I arbitrarily left them untouched -- refer to the paper for more information
  ltone = 7.0 ; utzero = 18.66

  p = 0.398942280444 ; q = 0.39990348504 ; r = 0.398942280385
  a1 = 5.75885480458 ; a2 = 2.62433121679 ; a3 = 5.92885724438
  b1 = -29.8213557807 ; b2 = 48.6959930692
  c1 = -3.8052E-8 ; c2 = 3.98064794E-4 ; c3 = -0.151679116635 ; c4 = 4.8385912808 ; c5 = 0.742380924027 ; c6 = 3.99019417011
  d1 = 1.00000615302 ; d2 = 1.98615381364 ; d3 = 5.29330324926 ; d4 = -15.1508972451 ; d5 = 30.789933034

  up = upper
  z = x
  if z < 0.0
     up = !up
     z = -z
  end
  if (z <= ltone or (up and z <= utzero))
     y = 0.5*z*z
     if (z > con)
        fn_val = r*Math.exp(-y)/(z+c1+d1/(z+c2+d2/(z+c3+d3/(z+c4+d4/(z+c5+d5/(z+c6))))))
     else
        fn_val = 0.5 - z*(p-q*y/(y+a1+b1/(y+a2+b2/(y+a3))))
     end
  else
     fn_val = 0.0
  end

  if (!up) ; fn_val = 1.0 - fn_val ; end

  fn_val
end

require 'gsl'
BITLY_LOGIN = "plotti"
BITLY_API_KEY = "R_fb1f65003bba56b566ed65be4a773741"

def self.get_urls (text)
  a = text.gsub(/((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/).to_a   
end

def self.get_expanded_urls (text)
  results = []
  if get_urls(text) != []    
    get_urls(text).each do |url|     
      if URI.parse(url).host == "bit.ly"
        begin
          tmp_res = self.expand_url(:params => {:shortUrl => url})
        rescue
        end
        if tmp_res != nil
          temp = tmp_res["results"]
          errorcode = tmp_res["statusCode"]          
          if errorcode != "ERROR"
            if temp != nil                 
              key = temp.keys.first
              results << temp[key]["longUrl"]
            end
          end
        end        
    else
      results << url
      end
    end      
  end
  return results
end

#user['Geo'] = Person.all.collect{|p| p.description}
#user['Verified'] = Person.all.collect{|p| p.description}
#user['Favorites_count'] = Person.all.collect{|p| p.description}
#user['TimeZone'] = Person.all.collect{|p| p.description}

persons = []
Person.all.each do |p|
  user = {}
  user['id']              = p.twitter_id
  user['username']        = p.username
  user['friends']         = p.friends_count
  user['friends_log']     = Math.log(p.friends_count + 1)
  user['followers']       = p.followers_count
  user['followers_log']   = Math.log(p.followers_count + 1)
  user['messages']        = p.statuses_count
  user['created_at']      = p.acc_created_at
  user['account_age']     = (DateTime.now - p.acc_created_at).to_i
  user['messages_log']    = Math.log(p.statuses_count + 1)
  user['messages_per_day']= user['messages'] / user['account_age']
  user['description']     = p.bio
  user['location']        = p.location
  user['url']             = p.website
  user['protected']       = p.private
  user['last_tweet']      = p.get_last_entry.text rescue " "
  user['last_tweet_date'] = p.get_last_entry.published_at rescue ""
  user['links_in_tweet']  = get_expanded_urls(p.get_last_entry.text).first rescue " "
  persons << user 
end

friends_log_vector = GSL::Vector[persons.collect{|p| p['friends_log']}]
followers_log_vector = GSL::Vector[persons.collect{|p| p['followers_log']}]
messages_log_vector = GSL::Vector[persons.collect{|p| p['messages_log']}]

#Standardize the Values on the z
persons.each do |p|
  p['z_friends_log'] = (p['friends_log'] - friends_log_vector.mean) / friends_log_vector.sd
  p['z_followers_log'] = (p['followers_log'] - followers_log_vector.mean) / followers_log_vector.sd
  p['z_messages_log'] = (p['messages_log'] - messages_log_vector.mean) / messages_log_vector.sd
end  

#Plane
z_friends_log_vector = GSL::Vector[persons.collect {|p| p['z_friends_log']}]
z_followers_log_vector = GSL::Vector[persons.collect{|p| p['z_followers_log']}]
z_messages_log_vector = GSL::Vector[persons.collect{|p| p['z_messages_log']}]    
   
#Stützpunkte für die Ebene
x1 = (20 - friends_log_vector.mean) / friends_log_vector.sd
x2 = (20 - followers_log_vector.mean) / followers_log_vector.sd
x3 = (50 - messages_log_vector.mean) / messages_log_vector.sd

y1 = (50 - friends_log_vector.mean) / friends_log_vector.sd
y2 = (50 - followers_log_vector.mean) / followers_log_vector.sd
y3 = (200 - messages_log_vector.mean) / messages_log_vector.sd

z1 = (83 - friends_log_vector.mean) / friends_log_vector.sd
z2 = (83 - followers_log_vector.mean) / followers_log_vector.sd
z3 = (123 - messages_log_vector.mean) / messages_log_vector.sd

p1 = GSL::Vector[x1,x2,x3]
p2 = GSL::Vector[y1,y2,y3]
p3 = GSL::Vector[z1,z2,z3]
   
#Vektoren b und c
b = p2-p1
c = p3-p1

# k = kreuzprodukt aus b und c
# d = a*x1 + b*x2 + c*x3
k = GSL::Vector[b[1]*c[2] - b[2]*c[1], b[2]*c[0]-b[0]*c[2], b[0]*c[1]-b[1]*c[0]]   
d = p1[0]*k[0] + p1[1]*k[1] + p1[2]*k[2]

#Calculate Distances to edges. Friends right, Followers up, Messages back. 
#Edges Front#Edges Back 
#34#67
#12#58
Z = 1.64
persons.each do |p|
  p['d1'] = Math.sqrt((-Z-p['z_messages_log'])**2 + (-Z-p['z_friends_log'])**2 + (-Z-p['z_followers_log'])**2)
  p['d2'] = Math.sqrt((-Z-p['z_messages_log'])**2 + (Z-p['z_friends_log'])**2 + (-Z-p['z_followers_log'])**2)
  p['d3'] = Math.sqrt((-Z-p['z_messages_log'])**2 + (-Z-p['z_friends_log'])**2 + (Z-p['z_followers_log'])**2)
  p['d4'] = Math.sqrt((-Z-p['z_messages_log'])**2 + (Z-p['z_friends_log'])**2 + (Z-p['z_followers_log'])**2)
  p['d5'] = Math.sqrt((Z-p['z_messages_log'])**2 + (-Z-p['z_friends_log'])**2 + (-Z-p['z_followers_log'])**2)
  p['d6'] = Math.sqrt((Z-p['z_messages_log'])**2 + (Z-p['z_friends_log'])**2 + (-Z-p['z_followers_log'])**2)
  p['d7'] = Math.sqrt((Z-p['z_messages_log'])**2 + (-Z-p['z_friends_log'])**2 + (Z-p['z_followers_log'])**2)
  p['d8'] = Math.sqrt((Z-p['z_messages_log'])**2 + (Z-p['z_friends_log'])**2 + (Z-p['z_followers_log'])**2)  
  p['e1'] = ( (k[0]*p['z_friends_log'] + k[1]*p['z_followers_log'] + k[2]*p['z_messages_log'] - d) / Math.sqrt(k[0]**2+k[1]**2+k[2]**2)).abs
  puts " d1:" + p['d1'].to_s + " d2:" + p['d2'].to_s + " d3:" + p['d3'].to_s + " d4:" + p['d4'].to_s
  puts " d5:" + p['d5'].to_s + " d6:" + p['d6'].to_s + " d7:" + p['d7'].to_s + " d8:" + p['d8'].to_s + " e1:" + p['e1'].to_s
end

persons.each do |p|
  min_distance = [p['d1'], p['d2'], p['d3'],p['d4'], p['d5'], p['d6'], p['d7'], p['d8'], p['e1']].min
  puts "MIN DISTANCE " + min_distance.to_s
  p['role_fit'] = 1 / Math.exp(min_distance)      
  p['role'] = case min_distance      
  when p['d1'] then "Passive Friender | Passive New User"
  when p['d2'] then "Passive Self Mareter | Passive Info Seeker"
  when p['d3'] then "Passive Authority"
  when p['d4'] then "Active Authority | Passive Friender"
  when p['d5'] then "Passive Bot | Apps | Active New User | Active Friender"
  when p['d6'] then "Active Self Marketer | Active Infoseeker | Active Spambot"    
  when p['d7'] then "Passive Broadcaster | Brand Marketing Apps"
  when p['d8'] then "Active Broadcaster | Very active Friender"
  when p['e1'] then "Friender"
	else "Unknown"
  end  
end

results = []
persons.each do |p|
  results <<  "USERNAME"+ p['username'] + "FRIENDS: " + p['friends'].to_s + " FOLLOWERS" + p['followers'].to_s + p[' MESSAGES: '].to_s +
        " ROLLE: " + p['role'] + " FIT: " + p['role_fit'].to_s + "Ebene" + p['e1'].to_s
end
break
