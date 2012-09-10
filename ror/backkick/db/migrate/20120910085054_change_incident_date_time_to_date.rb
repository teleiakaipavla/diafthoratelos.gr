class ChangeIncidentDateTimeToDate < ActiveRecord::Migration
  def up
    change_column :incidents, :incident_date, :date
  end

  def down
    change_column :incidents, :incident_date, :datetime
  end
end
