class CreateKnowledges < ActiveRecord::Migration
  def change
   create_table :knowledges do |t|
     t.string  :title, :null => true, :limit => 100
     t.string  :file_id

     t.timestamps
   end

  end
end