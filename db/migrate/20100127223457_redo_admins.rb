class RedoAdmins < ActiveRecord::Migration
  def self.up
    drop_table :admins
    
    create_table :admins do |t|
      t.string :firstname
      t.string :lastname
      t.string :uid
      t.string :email
      t.integer :access
    end
  end

  def self.down
    drop_table :admins
    
    create_table :admins do |t|
      t.string :user
      t.integer :access
    end
  end
end
