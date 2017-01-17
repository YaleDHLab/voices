class RemoveUrlsFromRecords < ActiveRecord::Migration
  def change
    remove_column :records, :source_url
  end
end
