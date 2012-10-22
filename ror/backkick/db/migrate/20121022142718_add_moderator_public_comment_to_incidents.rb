class AddModeratorPublicCommentToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :moderator_public_comment, :text
  end
end
