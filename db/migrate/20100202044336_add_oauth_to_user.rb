class AddOauthToUser < ActiveRecord::Migration
  def self.up
    drop_table :users

    create_table :users do |t|
      t.string :username
      t.string :firstname
      t.string :lastname
      t.string :uid
      t.string :email
      t.string :asecret
      t.string :atoken
    end
  end

  def self.down
    drop_table :users

    create_table :users do |t|
      t.string :username
      t.string :firstname
      t.string :lastname
      t.string :uid
      t.string :email
    end
  end
end
