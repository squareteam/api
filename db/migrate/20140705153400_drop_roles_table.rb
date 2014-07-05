# 201407153400
class DropRolesTable < ActiveRecord::Migration
  def change
    change_table :user_roles do |t|
      t.integer :permissions, :null => false, :default => 0, :limit => 8
    end

    remove_column :user_roles, :role_id

    drop_table :roles
  end
end
