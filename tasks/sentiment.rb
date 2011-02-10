require 'classifier'
b = Classifier::Bayes.new 'positive', 'negative'

def train(file, category, classifier)
  File.open(file).each { |line|
    line.split(" ").each do |word|
      if word =~/[a-zA-Z]/
        word.gsub!(/[|][A-Z]*/,"")
        word.split(",").each do |sub|
          classifier.train category, sub
        end
      end
    end
  }
end

train("positive.txt", :positive, b)
train("negative.txt", :negative, b)