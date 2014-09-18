class ChangeProjects < ActiveRecord::Migration
  # 20140917211504
  def change
    change_table :projects do |t|
      t.remove :created_by
      t.integer :owner_id, :null => false
      t.string :owner_type, :null => false
    end
  end
end
