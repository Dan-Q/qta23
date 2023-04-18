class AddTagsToInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :tags, :text
    add_column :invitations, :rsvp, :string
  end
end
