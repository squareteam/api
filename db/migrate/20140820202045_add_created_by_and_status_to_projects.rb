class AddCreatedByAndStatusToProjects < ActiveRecord::Migration
  # 20140820202045
  def change
    change_table :projects do |t|
      t.integer :status, :null => false, :default => '0', :limit => 1
      t.integer :created_by, :null => false
    end
  end
end
