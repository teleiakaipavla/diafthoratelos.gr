class RenameIncidentStatusToApprovalStatus < ActiveRecord::Migration
  def change
    rename_column :incidents, :status, :approval_status
  end
end
