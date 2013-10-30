class AddItemHabtmTables < ActiveRecord::Migration
  def change
  	create_table :item_stages_stats do |t|
  		t.integer :item_stage_id
  		t.integer :item_stat_id
  	end

  	create_table :item_effects_stages do |t|
  		t.integer :item_stage_id
  		t.integer :item_effect_id
  	end
  end
end
