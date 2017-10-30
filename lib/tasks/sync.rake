require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'odyssey'

AutoTagging.services = [:yahoo]

namespace :sync do
  task feeds: [:environment] do
    Feed.all.each do |feed|
      content = Feedjira::Feed.fetch_and_parse feed.url
      content.entries.each do |entry|
        puts entry.url
	#text = Nokogiri::HTML(open(entry.url))
        #content = text.css("p").text
	#response = AutoTagging.get_tags(entry.title)
        #readability = Odyssey.flesch_kincaid_re(content, false)
        #response.each do |t|
        #  puts t
        #  #Tag.where(name: name).first_or_create!
        #end
	local_entry = feed.articles.where(title: entry.title).first_or_initialize
        #local_entry.update_attributes(content: entry.content, author: entry.author, url: entry.url, published: entry.published)
        local_entry.update_attributes(author: entry.author, url: entry.author, published: entry.published)
	p "Synced Entry - #{entry.title}"
      end
      p "Synced Feed - #{feed.name}"
    end
  end
end
