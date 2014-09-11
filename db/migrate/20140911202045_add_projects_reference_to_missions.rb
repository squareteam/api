class AddProjectsReferenceToMissions < ActiveRecord::Migration
  def change
    change_table :missions do |t|
      t.references :project, :null => false
    end
  end
end
