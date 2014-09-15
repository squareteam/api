class ChangeDescriptionLimitOnMissions < ActiveRecord::Migration
  def change
    change_column :missions, :description, :text, :limit => 5000, :default => nil, :null => true
  end
end
