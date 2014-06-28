# 20140517120313
class AddColumnsToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.integer :admin_team_id, :null => true, :default => 0
    end
  end
end
