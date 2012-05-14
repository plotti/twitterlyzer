# Run all integrity checks in a row

#Check if for each person enough tweets and retweets have been collected (individual list)
system("ruby check_persons.rb")
#Check if for each interest community we have enough list counts, persons, retweets (aggregated list)
system("ruby check_communities.rb")
#Check the distribution of the list counts, plot graphs showing the distribution
system("ruby check_lists.rb")
#Analyze the resulting Networks with Python, check for basic parameters {#nodes, #ties, density, clustering}
system("python check_networks.py")