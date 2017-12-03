class Article < ApplicationRecord
	belongs_to :feed
  	has_many :photos, dependent: :destroy
  	scoped_search on: [:title]
end