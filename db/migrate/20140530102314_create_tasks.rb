class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string    :title, :null => false, :limit => 125
      t.string    :description, :null => false, :limit => 5000
      t.boolean   :closed, :default => 0
      t.datetime  :deadline, :null => true

      t.timestamps
    end
  end
end
