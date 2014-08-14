class AddStatusToProjects < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.string :status, :null => false, :default => 'inprogress', :limit => 20
    end
  end
end
