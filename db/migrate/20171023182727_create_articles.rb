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

      t.timestamps
    end
  end
end
