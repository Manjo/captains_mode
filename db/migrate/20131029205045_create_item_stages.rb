class CreateItemStages < ActiveRecord::Migration
  def change
    create_table :item_stages do |t|
      t.integer :stage
      t.integer :cost
      t.integer :refund
      t.belongs_to :item

      t.timestamps
    end
  end
end
