class ChampionPick < ActiveRecord::Base
	belongs_to :team
	belongs_to :champion
end
