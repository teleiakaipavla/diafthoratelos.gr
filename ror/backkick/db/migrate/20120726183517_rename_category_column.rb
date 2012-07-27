class RenameCategoryColumn < ActiveRecord::Migration
  def change
    rename_column :public_entities, :category, :category_id
  end
end
