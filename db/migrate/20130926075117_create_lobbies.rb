class CreateLobbies < ActiveRecord::Migration
  def change
    create_table :lobbies do |t|
      t.string :state
      t.string :team_one
      t.string :team_two
      t.text :ban_one
      t.text :ban_two
      t.text :pick_one
      t.text :pick_two
      t.string :unique_token

      t.timestamps
    end
  end
end
