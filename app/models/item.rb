class Item < ActiveRecord::Base
	has_many :stages, -> { order("stage ASC") }, class_name: 'ItemStage'
end
