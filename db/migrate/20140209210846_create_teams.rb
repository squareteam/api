class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, :null => false, :limit => 125
      t.references :organization, :null => false

      t.timestamps
    end
    add_index :teams, :name, :unique => true
    add_index :teams, [:name, :organization_id], :unique => true
  end
end
