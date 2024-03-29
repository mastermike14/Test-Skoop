class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :uid

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
