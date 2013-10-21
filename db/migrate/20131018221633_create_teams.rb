class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :captain_id
      t.belongs_to :lobby

      t.timestamps
    end
  end
end
