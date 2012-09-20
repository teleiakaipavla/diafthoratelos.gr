class AddPraiseToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :praise, :boolean, :default => false
  end
end
