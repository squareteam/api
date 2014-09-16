class AddColorToTeams < ActiveRecord::Migration
  def change
    change_table :teams do |t|
      t.string :color, :null => false, :default => '#2cc1ff', :limit => '7' # hexadecimal color (including '#')
    end
  end
end
