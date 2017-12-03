class Photo < ApplicationRecord
	 belongs_to :article, optional: true
	 has_many :tags
end
