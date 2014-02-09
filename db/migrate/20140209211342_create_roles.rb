class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :null => false, :limit => 125
      t.references :team, :null => false
      t.integer :permissions, :null => false, :default => 0, :limit => 32

      t.timestamps
    end
    add_index :roles, [:name, :team_id], :unique => true
  end
end
