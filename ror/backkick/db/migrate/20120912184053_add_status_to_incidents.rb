class AddStatusToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :status, :string, :default =>
      Incident::PENDING_STATUS
  end
end
