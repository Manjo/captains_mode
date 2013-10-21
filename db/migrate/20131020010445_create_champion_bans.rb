class CreateChampionBans < ActiveRecord::Migration
  def change
    create_table :champion_bans do |t|
    	t.belongs_to :champion
    	t.belongs_to :team
    	t.timestamps
    end
  end
end
