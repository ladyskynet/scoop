class CreateArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :author
      t.string :url
      t.datetime :published
      t.text :content
      t.float :readability
      t.integer :feed_id
      t.integer :wordcount
      t.float :sentimentality
      t.float :bias
      t.integer :string_length
      t.integer :letter_count
      t.integer :syllable_count
      t.integer :sentence_count
      t.float :average_words_per_sentence
      t.float :average_syllables_per_word
      t.timestamps
    end
  end
end
