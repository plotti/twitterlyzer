# Run all tests in a row

system("ruby analyze_persons.rb")
system("ruby analyze_communities.rb")
system("ruby analyze_lists.rb")

#Analyze the resulting Networks with Python

system("python analyze_networks.py")