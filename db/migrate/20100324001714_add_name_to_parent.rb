class AddNameToParent < ActiveRecord::Migration
  def self.up
    add_column :parents, :name, :string
    add_column :parents, :user_id, :integer
    add_index :parents, :user_id
  end

  def self.down
    remove_column :parents, :name
    remove_column :parents, :user_id
    remove_index :parents, :user_id
  end
end
