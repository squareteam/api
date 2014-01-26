class User < ActiveRecord::Base
  validates_presence_of :email, :pbkdf, :salt
  validates :email, :uniqueness => true, format: { with: /\A\w{1}(\w|\.|\+)*\w{1}@\w{1}(\w|\.)*(\.){1}(\w|\.)*\w{1}\Z/ }, :on => :create
end
