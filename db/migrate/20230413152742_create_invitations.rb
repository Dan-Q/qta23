class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.string :name
      t.text :notes
      t.text :private_notes
      t.string :code
      t.datetime :last_login
      t.text :emails
      t.text :phones
      t.text :guests

      t.timestamps
    end
    add_index :invitations, :code, unique: true
  end
end
