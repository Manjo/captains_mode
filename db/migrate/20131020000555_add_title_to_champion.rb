class AddTitleToChampion < ActiveRecord::Migration
  def change
  	add_column :champions, :title, :string
  end
end
