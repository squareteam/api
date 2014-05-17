# 20140517120313
class AddColumnsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :provider, :null => false, :default => '', :limit => 100
      t.string :uid, :null => false, :default => '', :limit => 254
      t.index [:uid, :provider], :unique => true
    end
  end
end
