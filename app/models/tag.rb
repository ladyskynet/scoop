class Tag < ApplicationRecord
	belongs_to :photo, optional: true
	#has_many :taggings
	#has_many :articles, through: :taggings
end
