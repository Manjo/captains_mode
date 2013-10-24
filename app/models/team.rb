class Team < ActiveRecord::Base
	belongs_to :lobby
	has_many :bans, class_name: 'ChampionBan'
	has_many :picks, class_name: 'ChampionPick'

	def team_captain?(id)
		@captain_id == id
	end

	def picks(min=0)
		p = super

		if min > 0
			p = p.to_a
			(min - p.size).times do
				p << ChampionPick.new
			end
		end
		p
	end


	# If no arguments are supplied, acts normally by returning the
	# CollectionProxy. If a min is supplied, it will convert to an array
	# and try to fill the array to the minimum size
	def bans(min=0)
		b = super

		if min > 0
			b = b.to_a
			(min - b.size).times do
				b << ChampionBan.new
			end
		end

		b
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