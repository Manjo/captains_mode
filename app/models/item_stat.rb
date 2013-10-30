class ItemStat < ActiveRecord::Base
	self.inheritance_column = nil # So we can have a column named "type"
	has_and_belongs_to_many :item_stages

	def items
		Item.joins(:stages)
	end
end
