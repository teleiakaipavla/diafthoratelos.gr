class AddPlaceToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :place_id, :integer
  end
end
