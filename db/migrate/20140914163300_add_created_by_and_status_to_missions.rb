class AddCreatedByAndStatusToMissions < ActiveRecord::Migration
  def change
    change_table :missions do |t|
      t.integer :status, :null => false, :default => '0', :limit => 1
      t.integer :created_by, :null => false
    end
  end
end
