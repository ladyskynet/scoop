class AddPhotoIdToTag < ActiveRecord::Migration[5.1]
  def change
  	add_column :tags, :photo_id, :integer
  end
end
