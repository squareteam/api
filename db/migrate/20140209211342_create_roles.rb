class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :null => false, :limit => 125
      t.integer :permissions, :null => false, :default => 0, :limit => 8

      t.timestamps
    end
#    add_index :roles, [:name], :unique => true
  end
end
