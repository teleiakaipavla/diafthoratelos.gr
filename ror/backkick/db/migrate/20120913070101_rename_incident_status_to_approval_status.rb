class RenameIncidentStatusToApprovalStatus < ActiveRecord::Migration
  def change
    rename_column :incidents, :status, :incident_status
  end
end
