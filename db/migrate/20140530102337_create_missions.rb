class CreateMissions < ActiveRecord::Migration
  def change
   create_table :missions do |t|
     t.string    :title, :null => false, :limit => 125
     t.string    :description, :null => false, :limit => 5000
     t.datetime  :deadline, :null => true

     t.timestamps
   end
  end
end
