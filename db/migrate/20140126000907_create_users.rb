class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, :null => false, :default => '', :limit => 100
      t.string :email, :null => false, :limit => 100
      t.column :pbkdf, 'varbinary(256)', :null => false
      t.column :salt, 'varbinary(256)', :null => false

      t.timestamps
    end
    add_index :users, :email
  end
end
