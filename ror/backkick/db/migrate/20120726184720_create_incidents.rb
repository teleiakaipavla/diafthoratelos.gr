class CreateIncidents < ActiveRecord::Migration
  def change
    create_table :incidents do |t|
      t.datetime :incident_date
      t.decimal :money
      t.decimal :money_given
      t.text :description
      t.integer :public_entity_id

      t.timestamps
    end
  end
end
