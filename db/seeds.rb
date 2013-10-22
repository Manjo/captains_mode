champion_data = [
	{ name: "Arcane Green Lantern", role: "Support", title: "The Emerald Light" },
	{ name: "Atomic Wonder Woman", role: "Assassin", title: "The Reclaimer" },
	{ name: "Batman", role: "Bruiser", title: "The Caped Crusader" },
	{ name: "Catwoman", role: "Blaster", title: "Feline Fatale" },
	{ name: "Cyborg", role: "Marksman", title: "Human Arsenal" },
	{ name: "Doomsday", role: "Bruiser", title: "Ruthless Abomination" },
	{ name: "Flash", role: "Assassin", title: "The Fastest Man Alive" },
	{ name: "Gaslight Batman", role: "Marksman", title: "The Sonic Knight" },
	{ name: "Gaslight Catwoman", role: "Assassin", title: "Protector of the Weak" },
	{ name: "Gaslight Joker", role: "Enforcer", title: "The Laughing Butcher" },
	{ name: "Green Lantern", role: "Blaster", title: "Protector of Sector 2814" },
	{ name: "Joker", role: "Blaster", title: "Clown Prince of Crime" },
	{ name: "Nightmare Batman", role: "Assassin", title: "Vampire Batman" },
	{ name: "Poison Ivy", role: "Support", title: "Deadly Rose" },
	{ name: "Shazam", role: "Bruiser", title: "Earth's Mightiest Mortal" },
	{ name: "Wonder Woman", role: "Enforcer", title: "Ambassador of Peace" },
	{ name: "Zatanna", role: "Support", title: "Showstopper" }
]

# TODO: Find a better way to update rather than blowing up all the seed data
Champion.destroy_all
champion_data.each do |c|
	Champion.find_or_create_by(c)
end

# Only for development purposes!
if Rails.env == "development"
	l = Lobby.new
	l.register("Team One")
	l.register("Team Two")
	l.ban(:team_one, "Wonder Woman")
	l.ban(:team_two, "Flash")
	l.pick(:team_one, "Batman")
	l.pick(:team_two, "Cyborg")
	l.pick(:team_two, "Catwoman")
	l.pick(:team_one, "Shazam")
	l.pick(:team_one, "Zatanna")
	l.pick(:team_two, "Joker")
	l.pick(:team_two, "Green Lantern")
	l.pick(:team_one, "Doomsday")
	l.pick(:team_one, "Gaslight Batman")
	l.pick(:team_two, "Gaslight Joker")
end