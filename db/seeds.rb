# TODO: Find a better way to update rather than blowing up all the seed data... use Seed-Fu
# and a custom solution so that it acts like migrations?
VERBOSE = false

def announce(message)
  length = [0, 75 - message.length].max
  puts "== %s %s" % [message, "=" * length]
end

def say(message, subitem=false)
	puts "#{subitem ? "#{"   " * subitem}->" : "--"} #{message}"
end

def say_with_time(message)
  say(message)
  result = nil
  time = Benchmark.measure { result = yield }
  say "%.4fs" % time.real, 1
  say("#{result} rows", 1) if result.is_a?(Integer)
  result
end

announce("Create Champions: Adding")
say_with_time("Destroying existing champions") do
	Champion.destroy_all
end

say_with_time("Adding champions") do
	champion_data = ActiveSupport::JSON.decode(File.read("#{Rails.root}/db/seeds/champions.json"))
	champion_data.each do |c|
		say "Adding #{c["name"]}: #{c["title"]} as #{c["role"]}", 2 if VERBOSE
		Champion.create(c)
	end
end
announce("Create Champions: Added")
puts "\n"

# TODO: Add effect tags
announce("Create Effects: Adding")
say_with_time("Destroying existing effects") do
	ItemEffect.destroy_all
end
say_with_time("Adding effects") do
	effects_data = ActiveSupport::JSON.decode(File.read("#{Rails.root}/db/seeds/effects.json"))
	effects_data.each do |data|
		name = data["name"]
		resource = name.parameterize.underscore
		type = data["type"]
		desc = data["desc"]
		say "Adding #{type} effect: #{name}(#{resource}), #{desc}", 2 if VERBOSE
		ItemEffect.where(resource: resource, name: name, type: type, description: type).first_or_create
	end
end
announce("Create Effects: Added")
puts "\n"


announce("Create Items: Adding")
say_with_time("Destroying existing items") do
	[Item, ItemStage, ItemStat].each { |db| db.destroy_all }
end

say_with_time("Adding items") do
	item_data = ActiveSupport::JSON.decode(File.read("#{Rails.root}/db/seeds/items.json"))
	item_data.each do |data|
		say "Adding #{data["name"]}:", 2 if VERBOSE
		item = Item.new(name: data["name"])
		data["stages"].each_with_index do |s, i|
			stage = ItemStage.new(stage: i, cost:s["buy"], refund:s["sell"])
			say "#{data["name"]} (#{i}): ", 3 if VERBOSE

			s["stats"].each do |type, value|
				say "#{type}: #{value}", 4 if VERBOSE
				stat = ItemStat.where(type: type, value: value).first_or_initialize
				stage.stats << stat
			end

			s["effects"].each do |name|
				resource = name.parameterize.underscore
			  	say "#{resource}", 4 if VERBOSE
				effect = ItemEffect.find_by_resource(resource)
				stage.effects << effect
			end unless s["effects"].nil?

			item.stages << stage
		end
		item.save
	end
end
announce("Create Items: Added")
puts "\n"

# Only for development purposes!
if Rails.env == "development"
	announce("Creating Lobby: Adding")
	say_with_time("Destroying existing Lobbies") do
		Lobby.destroy_all
	end
	say_with_time("Creating test lobby") do
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
		l.token = "a"
		l.save	
	end
	announce("Creating Lobby: Added")
end