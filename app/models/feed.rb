require 'rss'
require 'open-uri'

class Feed < ActiveRecord::Base
    has_many :articles, dependent: :destroy
    def self.search_url(search)
        if search.present?
            #Feed.where('url = ?', search)
            Feed.where('url LIKE ?', "%#{search}%")
        else
            Feed.all
        end
    end
    def self.validate_feed(valid_test)
        begin
            open(valid_test) do |rss|
                feed = RSS::Parser.parse(rss)
                #v = W3C::FeedValidator.new()
                #v.validate_url(valid_test)
                #return false unless v.valid?
                #return true
                return true
            end
        rescue
            return false
        end
    end
end

