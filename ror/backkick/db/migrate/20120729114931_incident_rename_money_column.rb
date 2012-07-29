class IncidentRenameMoneyColumn < ActiveRecord::Migration
  def change
    rename_column :incidents, :money, :money_asked
  end
end
