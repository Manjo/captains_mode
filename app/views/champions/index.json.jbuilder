json.array!(@champions) do |champion|
  json.extract! champion, :name, :role
  json.url champion_url(champion, format: :json)
end
