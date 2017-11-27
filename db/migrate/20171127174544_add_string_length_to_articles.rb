class AddStringLengthToArticles < ActiveRecord::Migration[5.1]
  def change
    # add_column table_name, :column_name, :column_type
    add_column :articles, :string_length, :integer
    add_column :articles, :letter_count, :integer
    add_column :articles, :syllable_count, :integer
    add_column :articles, :sentence_count, :integer
    add_column :articles, :average_words_per_sentence, :float
    add_column :articles, :average_syllables_per_word, :float
  end
end
