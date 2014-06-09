class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, :null => false
      t.references :role, :null => false
      t.references :team, :null => false

      t.timestamps
    end
    add_index :user_roles, [:user_id, :team_id, :role_id], :unique => true
  end
end
