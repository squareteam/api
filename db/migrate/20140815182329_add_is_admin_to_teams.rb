class AddIsAdminToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :is_admin, :boolean, default: false, null: false
  end
end
