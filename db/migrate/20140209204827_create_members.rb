class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.references :organization, :null => false
      t.references :user, :null => false
      t.boolean :admin, :null => false, :default => false

      t.timestamps
    end
    add_index :members, [:organization_id, :user_id], :unique => true
  end
end
