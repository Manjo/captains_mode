class CreateChampionPicks < ActiveRecord::Migration
  def change
    create_table :champion_picks do |t|
      t.belongs_to :champion
      t.belongs_to :team
      t.timestamps
    end
  end
end
