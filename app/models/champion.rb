class Champion < ActiveRecord::Base
	has_many :champion_bans, as: :bans
	has_many :champion_picks, as: :picks
end
