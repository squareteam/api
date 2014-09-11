class AddMissionsReferenceToTasks < ActiveRecord::Migration
  def change
    change_table :tasks do |t|
      t.references :mission, :null => false
    end
  end
end
