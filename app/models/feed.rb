require 'rss'
require 'open-uri'

class Feed < ActiveRecord::Base
    has_many :articles, dependent: :destroy
    #Searches too see if a url is already in the database
    def self.search_url(search)
        if search.present?
            #Where url is like another, not the exact same
            Feed.where('url LIKE ?', "%#{search}%")
        else
            Feed.all
        end
    end
    #Test feed to see if it is valid rss
    def self.validate_feed(valid_test)
        begin
            #Does a test parse of the feed
            open(valid_test) do |rss|
                feed = RSS::Parser.parse(rss)
                #Return true if valid feed
                return true
            end
        rescue
            #If not valid
            return false
        end
    end
end