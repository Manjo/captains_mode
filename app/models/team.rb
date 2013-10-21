class Team < ActiveRecord::Base
	belongs_to :lobby
	has_many :bans, class_name: 'ChampionBan'
	has_many :picks, class_name: 'ChampionPick'

	def team_captain?(id)
		@captain_id == id
	end

	def ban(champion)
		ban = ChampionBan.new(champion: champion)
		bans << ban
	end

	def pick(champion)
		pick = ChampionPick.new(champion: champion)
		picks << pick
	end
end