require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'odyssey'
require 'words_counted'
require 'mechanize'
require 'sentimental'

#AutoTagging.services = [:yahoo]

mechanize = Mechanize.new { |a|
  a.post_connect_hooks << lambda { |_,_,response,_|
    if response.content_type.nil? || response.content_type.empty?
      response.content_type = 'text/html'
    end
  }
}

# Create an instance for usage
analyzer = Sentimental.new
# Load the default sentiment dictionaries
analyzer.load_defaults

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
            mechanize.get(entry.url)
            #puts page.content
          rescue Exception => e
            p e.message
          end

          mechanize.page.parser.class
          # => Nokogiri::HTML::Document

          article_content = mechanize.page.parser.css("p").text
          if article_content != "" 
            sentimentality_score = analyzer.score article_content
            p sentimentality_score
            total_readability = Odyssey.flesch_kincaid_re(article_content, true)
            local_entry.update_attributes(wordcount: total_readability['word_count'], readability: total_readability['score'], content: article_content, string_length: total_readability['string_length'], letter_count: total_readability['letter_count'], syllable_count: total_readability['syllable_count'], sentence_count: total_readability['sentence_count'], average_words_per_sentence: total_readability['average_words_per_sentence'], average_syllables_per_word: total_readability['average_syllables_per_word'], sentimentality: sentimentality_score)  
          end
          begin
            local_entry.save!
          rescue Exception => e
            p e.message
          end
        end
        p "Synced Entry - #{entry.title}"
      end
      p "Synced Feed - #{feed.name}"
    end
  end
end
