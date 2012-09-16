class AdminController < ApplicationController
  def index
    @total_pending = Incident.where("approval_status = ?",
                                    Incident::PENDING_STATUS).count
  end
end
