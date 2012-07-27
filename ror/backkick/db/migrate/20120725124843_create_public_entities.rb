class CreatePublicEntities < ActiveRecord::Migration
  def change
    create_table :public_entities do |t|
      t.string :name

      t.timestamps
    end
  end
end
