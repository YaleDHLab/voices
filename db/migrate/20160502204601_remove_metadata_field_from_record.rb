class RemoveMetadataFieldFromRecord < ActiveRecord::Migration
  def change
    remove_column :records, :metadata
  end
end
