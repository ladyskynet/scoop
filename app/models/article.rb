class Article < ApplicationRecord
belongs_to :feed
  has_many :photos
  scoped_search on: [:title]
end