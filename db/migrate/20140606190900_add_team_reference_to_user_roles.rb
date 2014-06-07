class AddTeamReferenceToUserRoles < ActiveRecord::Migration
  def change

    add_column :user_roles, :team_id, :integer

    add_index :user_roles, :team_id

    remove_column :user_roles, :role_id

  end
end
