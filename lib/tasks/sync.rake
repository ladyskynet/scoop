require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'odyssey'
require 'mechanize'
require 'sentimental'
require 'google/cloud/vision'
require 'google/cloud/storage'

 # Your Google Cloud Platform project ID
project_id = "scoop-187818"
key_file   = {
  "type": "service_account",
  "project_id": "scoop-187818",
  "private_key_id": "f95e3acc351fe3b532279ecc109e5117d2729e1d",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQD4m2gDyHu1Cxfj\nGNhlvBR2GQZ0kjllJqTdLPGraReOIm8NkwgLi+BowqemMlspjr2+iWfwOGhwnnoY\ngGKfNqrHOnk/ahWWLuktroRYDgw96/wJSiUVh6ZA4z5eH9MgYpAO3lP6iam3tA90\nFosfIkElOkUWAp3w9/hfryQJAkQRN6b/LoAUGWO55nxPl6ksbXVzOatWLNYoD3rH\nt+h0StqEleGFQW4t5BgTCmru1AGeP4TNLoYI4e8gRkClhoLMbyQuvWU3ek2pxvXR\nK0FEqN/mhaJqh59RigK5mR6kil4DHx+4pPhYVZr/0hqa1OXn0tVa1u710xuP3Xoc\nBHdj6Rj5AgMBAAECggEABTJqeDnGrEAxHaQ1UdseqmFXizRLUtv98kmwO58UyPnb\nTHNYZbVk2YvIKWdAFJxRRxxkOddUB5aogr6cUSu5YjTMuBClpuAQK85MIfMZOmom\neKM+JzcQuKaHdTxBE5o73LO1GbWrAJYZBJo8CkiTCA4xx4YCezkTzhxBKpcLiTiQ\nDvdEsD3mwIFEupMGQZ7pgmC+zv9qNX2I+p+/G9otJ6ZejR/NchiWfAVYekdwb+CP\n01jnB/FwErXbnEDgP5mzk1bXcHSoremUU2gWlZWHjoyYHz6rg51rROnUhJtpgfdj\nz+QKD/byVB3l3rC8NrtRJr1BnWJFWztbvVJpWCZ7yQKBgQD9OIuDVPNfvc6iFPzD\nACW6b7EM2r4mdABVmNcQUgxs7GnfwwRC8T1cG99/hrOPXPWxMfbJ2RcmQXGUiuoU\no6UCy+ifny3i/Nz7sUk9++wZuK5oQrqbxa5k7WaEZJoAUI+HDL8+tsYTPmUMTlD/\nl+OAmdvZFvwYMOU511FJENOnhwKBgQD7VeXyv2l5Qfm5Xub7unM+smNmGRn/4nLX\na0kpriZSWFqvQrvBHl+eU+HzUza8YT3sSfveaUH/x6xAE8sNRrJdvBKqEh0dlPKH\nNRuRXCZTDsskgnepzLYUNKJzrLSMh2pD+InMUQWSZRL9vsLjy7mJcC44IiGejwvg\nd98n3cRbfwKBgEooWitPIKtEUhSDovaUv3fXJ/nEwfVO+Z4X0bwU21C299axLTlR\nnw+vlgep8kIlDksjf8vjSPVKKzI+cIk016l3ABxnKLAWL72CURnXAnER9fnQuQfP\nn+As6l4RfExlS3NYl1WNf3q5RiyRbwU7fUP3SzxLj+6huy/yT/re861XAoGBAK21\nBZOLpasv5RewNrZ+e842Xqqe6LBI4xRtywgqm8PH2w1McxWbF30G/qA8wBTcpH6d\n950VZI8SgsNaqrkHRpmwNbojgMoEOscl9mK1rKs1C0O1hFzv5lv6sNh/4d1KbjCC\nI0L6MH6oqsKDSJFGKXqK9PbI6DF9Ljk6wBn+lQqjAoGBANrSp0kHL4UH2QS8uJcN\nhc5sKdNPoZNyX7BuSXcCZblxho+BOcFQQ+3vTA83E6P1XPOCDI6TOqffBU2XnMGV\n8Ziit2ok2s437/0jHORRTgCKZ5t+IsFrcsSydXcPw+re8JvXC1DnkS9a92ET3j0N\nFGes+RqcnW/MIWN+5rGHx+kU\n-----END PRIVATE KEY-----\n",
  "client_email": "scoop-337@scoop-187818.iam.gserviceaccount.com",
  "client_id": "110883541733537615883",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/scoop-337%40scoop-187818.iam.gserviceaccount.com"
}


# Explicitly use service account credentials by specifying the private keyfile.
#storage = Google::Cloud::Storage.new project: project_id, keyfile: key_file

# Make an authenticated API request
#storage.buckets.each do |bucket|
#  puts bucket.name
#end

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
            local_entry.save!
          rescue Exception => e
            p e.message
          end

          begin
            mechanize.get(entry.url)
            mechanize.page.images.each do |imageUrl|
              newImage = Photo.new(url: imageUrl, article_id: local_entry)
              begin
                newImage.save!
              rescue Exception => e
                p e.message
              end
              # Instantiates a client
              vision = Google::Cloud::Vision.new project: project_id, keyfile: key_file

              # Performs label detection on the image file
              labels = vision.image(imageUrl).labels
              labels.each do |label|
                newTag = Tag.new(name: label.description, photo_id: newImage.id)
                newTag.save!
              end
              
             
            end
            #puts page.content
          rescue Exception => e
            p e.message
          end

          mechanize.page.parser.class
          # => Nokogiri::HTML::Document

          article_content = mechanize.page.parser.css("p").text
          if article_content != "" 
            sentimentality_score = analyzer.score article_content
            total_readability = Odyssey.flesch_kincaid_re(article_content, true)
            local_entry.update_attributes(wordcount: total_readability['word_count'], readability: total_readability['score'], content: article_content, string_length: total_readability['string_length'], letter_count: total_readability['letter_count'], syllable_count: total_readability['syllable_count'], sentence_count: total_readability['sentence_count'], average_words_per_sentence: total_readability['average_words_per_sentence'], average_syllables_per_word: total_readability['average_syllables_per_word'], sentimentality: sentimentality_score)  
          end
        end
        p "Synced Entry - #{entry.title}"
      end
      p "Synced Feed - #{feed.name}"
    end
  end
end
