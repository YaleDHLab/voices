class RenameMakePrivateToMakePublic < ActiveRecord::Migration
  def change
    remove_column :records, :make_private
    add_column :records, :make_public, :boolean
  end
end
