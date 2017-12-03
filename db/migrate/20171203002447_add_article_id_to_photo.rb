class AddArticleIdToPhoto < ActiveRecord::Migration[5.1]
  def change
  	add_column :photos, :article_id, :integer
  end
end
