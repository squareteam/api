class CreateTaskComments < ActiveRecord::Migration
  def change
   create_table :task_comments do |t|
     t.string     :text, :null => false, :limit => 5000

     t.references :task, :null => false
     t.references :user, :null => false

     t.timestamps
   end

   add_index :task_comments, :task_id
   
  end
end
