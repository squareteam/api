class CreateProjectAccesses < ActiveRecord::Migration
  def change
   create_table :project_accesses do |t|
     t.string     :object_type, :null => false
     t.integer    :object_id, :null => false

     t.references :project, :null => false
   end

   add_index :project_accesses, [:object_id, :object_type]
   # Index to fetch all projects for a given object
   #  Example : get all project accessible for user with id = 1
  end
end
