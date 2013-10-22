class RemoveOldLobbyColumns < ActiveRecord::Migration
  def up
    remove_column :lobbies, :team_one
    remove_column :lobbies, :team_two
    remove_column :lobbies, :bans_one
    remove_column :lobbies, :bans_two
    remove_column :lobbies, :picks_one
    remove_column :lobbies, :picks_two
  end

  def down
  	add_column :lobbies, :team_one, :string
  	add_column :lobbies, :team_two, :string
  	add_column :lobbies, :bans_one, :text
  	add_column :lobbies, :bans_two, :text
  	add_column :lobbies, :picks_one, :text
  	add_column :lobbies, :picks_two, :text
  end
end
