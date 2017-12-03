class Photo < ApplicationRecord
	 belongs_to :article, optional: true
	 has_and_belongs_to_many :tags
end
