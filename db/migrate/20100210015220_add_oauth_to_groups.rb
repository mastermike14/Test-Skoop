class AddOauthToGroups < ActiveRecord::Migration
  def self.up
  drop_table :groups

  create_table :groups do |t|
      t.string :name
      t.string :owner
      t.string :desc
      t.integer :twitter_id
      t.string :atoken
      t.string :asecret

      t.timestamps
    end
  end

  def self.down
  end
end
