class ItemStage < ActiveRecord::Base
	belongs_to :item
	has_and_belongs_to_many :stats, class_name: 'ItemStat'
	has_and_belongs_to_many :effects, class_name: 'ItemEffect'
end
