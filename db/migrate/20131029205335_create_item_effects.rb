class CreateItemEffects < ActiveRecord::Migration
  def change
    create_table :item_effects do |t|
      t.string :resource
      t.string :name
      t.string :type
      t.string :description

      t.timestamps
    end
  end
end
