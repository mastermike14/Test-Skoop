class CreateParents < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.string :email
      t.string :asecret
      t.string :atoken

      t.timestamps
    end
  end

  def self.down
    drop_table :parents
  end
end
