class PluralizeLobbyColumns < ActiveRecord::Migration
  def change
    change_table :lobbies do |t|
      t.rename :ban_one, :bans_one
      t.rename :ban_two, :bans_two
      t.rename :pick_one, :picks_one
      t.rename :pick_two, :picks_two
    end
  end
end
