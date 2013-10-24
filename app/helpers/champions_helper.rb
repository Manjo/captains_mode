module ChampionsHelper

	def champion_headshot_path(c)
		"/images/headshots/#{champion_tag(c)}.jpg"
	end

	def champion_headshot_image(c, options={})
		return "" if c.nil?
		image_tag(champion_headshot_path(c), options)
	end

	def champion_portrait_path(c)
		"/images/portraits/#{champion_tag(c)}.jpg"
	end

	def champion_portrait_image(c, options={})
		return "" if c.nil?
		image_tag(champion_portrait_path(c), options)
	end

	def champion_tag(c)
		c.name.parameterize.underscore
	end
	
end
