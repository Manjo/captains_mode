class CreateItemStats < ActiveRecord::Migration
  def change
    create_table :item_stats do |t|
      t.string :type
      t.string :value

      t.timestamps
    end
  end
end
