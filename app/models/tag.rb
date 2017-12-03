class Tag < ApplicationRecord
	belongs_to :photo, optional: true
end
