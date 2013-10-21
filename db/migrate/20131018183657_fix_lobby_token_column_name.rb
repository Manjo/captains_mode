class FixLobbyTokenColumnName < ActiveRecord::Migration
  def change
  	rename_column :lobbies, :unique_token, :token
  end
end
