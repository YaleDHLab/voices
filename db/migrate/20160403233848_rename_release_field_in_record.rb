class RenameReleaseFieldInRecord < ActiveRecord::Migration
  def change
    remove_column :records, :release_cheeked
    add_column :records, :release_checked, :boolean
  end
end
