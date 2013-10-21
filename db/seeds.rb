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