require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'odyssey'
require 'words_counted'
require 'mechanize'

#AutoTagging.services = [:yahoo]

a = Mechanize.new

namespace :sync do
  # For all feeds gather new articles
  task feeds: [:environment] do
    # On each feed do
    Feed.all.each do |feed|
 
     # Fetch article content if URL exists
      content = Feedjira::Feed.fetch_and_parse(feed.url)
      
      content.entries.each do |entry|
        article_content = ""
        local_entry = Article.find_by title: entry.title
        if local_entry.nil?
          p "Creating a new Article!"
          local_entry = Article.new(author: entry.author, url: entry.url, published: entry.published, title: entry.title, feed_id: feed.id)
          begin
            page = a.get(entry.url)
            #puts page.content
          rescue Exception => e
            p e.message
          end

          if page.nil?
            begin
              page = Nokogiri::HTML(open(entry.url))
              p "noko"
            rescue Exception => e
              p e.message
            end
          end
          page.css("p").each do |paragraph|
            # p ("Paragraph: "+paragraph)
            article_content += " " + paragraph
          end
          #puts ("Article Content: " + article_content)
          total_readability = Odyssey.flesch_kincaid_re(article_content, true)
          local_entry.update_attributes(wordcount: total_readability['word_count'], readability: total_readability['score'], content: article_content)  
          begin
            local_entry.save!
          rescue Exception => e
            p e.message
          end
        end
        p "Synced Entry - #{entry.title}"
        # p local_entry.wordcount
      end
      p "Synced Feed - #{feed.name}"
    end
  end
end
