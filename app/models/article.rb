#require 'Sentimental'

class Article < ApplicationRecord
	belongs_to :feed
	has_many :taggings
	has_many :tags, through: :taggings
    scoped_search on: [:title]

 

	#def all_tags=(names)
  	#	self.tags = names.split(",").map do |name|
      	#		Tag.where(name: name.strip).first_or_create!
  	#	end
	#end

	#def all_tags
  	#	self.tags.map(&:name).join(", ")
	#end

	#def sentimentalityScore (text)
    #    analyzer = Sentimental.new
    #    analyzer.load_defaults
    #    sentiment = analyzer.sentiment text
    #end
    #Function that analyzes the text and gives a bias score
    #def biasScore (text)
        #split the text into an array
    #    text = text.split;
        #compare the array to the bias dictionary
        #count the matches vs total lenght
    #end

end
