class RemoveFileUploadUrlFromRecords < ActiveRecord::Migration
  def change
    remove_column :records, :file_upload_url
  end
end
