class AddCategoryColumn < ActiveRecord::Migration
  def change
    add_column :public_entities, :category, :integer
  end
end
