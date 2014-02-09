class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name, :null => false, :limit => 125

      t.timestamps
    end
    add_index :organizations, :name, :unique => true
  end
end
