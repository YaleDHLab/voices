class AddFlaggedForRemovalBooleanToRecords < ActiveRecord::Migration
  def change
    add_column :records, :flagged_for_removal, :boolean
  end
end
