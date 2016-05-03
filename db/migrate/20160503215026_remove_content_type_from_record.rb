class RemoveContentTypeFromRecord < ActiveRecord::Migration
  def change
    remove_column :records, :content_type
  end
end
